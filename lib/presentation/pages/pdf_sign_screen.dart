// pdf_signature_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../services/api_client.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfSignatureScreen extends StatefulWidget {
  final String receptionId;
  final Uint8List pdfData;

  const PdfSignatureScreen({
    Key? key,
    required this.receptionId,
    required this.pdfData,
  }) : super(key: key);

  @override
  State<PdfSignatureScreen> createState() => _PdfSignatureScreenState();
}

class _PdfSignatureScreenState extends State<PdfSignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _loading = false;

  Future<void> _saveAndUploadSignature() async {
    final signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null) return;

    setState(() => _loading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      await apiClient.uploadSignedPdf(
        pdfBytes: widget.pdfData, // сервер объединяет PDF + подпись
        receptionId: widget.receptionId,
        signatureBytes: signatureBytes,
        filename: 'signed.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подписанный PDF отправлен на сервер')),
      );
      Navigator.pop(context, true); // вернем true, чтобы обновить PDF
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки PDF: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подпись документа')),
      body: Stack(
        children: [
          SfPdfViewer.memory(widget.pdfData),
          Positioned.fill(
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _signatureController.clear(),
                  child: const Text('Очистить подпись'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _saveAndUploadSignature,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить и отправить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
