import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneField extends StatelessWidget {
  final String phone;

  const PhoneField({super.key, required this.phone});

  Future<void> _callNumber(BuildContext context) async {
    if (phone.isEmpty) return;

    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть приложение телефона')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _copyNumber(BuildContext context) async {
    if (phone.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Номер скопирован')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Номер кликабелен для копирования
        Expanded(
          child: GestureDetector(
            onTap: () => _copyNumber(context),
            child: SelectableText(
              phone.isEmpty ? 'Не указан' : phone,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ),
        // Иконка для звонка
        IconButton(
          icon: const Icon(Icons.phone, size: 20),
          tooltip: 'Позвонить',
          onPressed: () => _callNumber(context),
        ),
      ],
    );
  }
}
