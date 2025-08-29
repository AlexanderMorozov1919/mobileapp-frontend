// pdf_viewer_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/api_client.dart';
import 'pdf_sign_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  final String receptionId;

  const PdfViewerScreen({Key? key, required this.receptionId}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfData;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() => _loading = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final data = await apiClient.getReceptionPdf(widget.receptionId);

      if (data.isEmpty) {
        throw Exception("Получен пустой PDF");
      }

      setState(() => _pdfData = data);

      // Для проверки можно сохранить PDF во временную папку
      await _debugSavePdf(_pdfData!);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки PDF: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _debugSavePdf(Uint8List pdfData) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/debug.pdf');
      await file.writeAsBytes(pdfData);
      print('PDF сохранён: ${file.path}');
    } catch (e) {
      print('Не удалось сохранить PDF для проверки: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Документ PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Подписать',
            onPressed: (_pdfData == null) ? null : () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfSignatureScreen(
                    receptionId: widget.receptionId,
                    pdfData: _pdfData!,
                  ),
                ),
              );
              if (updated == true) {
                _loadPdf(); // обновляем PDF после подписи
              }
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_pdfData == null)
              ? const Center(child: Text('PDF не загружен'))
              : SfPdfViewer.memory(_pdfData!),
    );
  }
}
