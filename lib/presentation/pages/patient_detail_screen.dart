import 'package:flutter/material.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  
  @override
void initState() {
  super.initState();
  
  // Инициализация контроллеров данными пациента
  _controllers['fullName'] = TextEditingController(
      text: widget.patient['fullName'] ?? '');
  _controllers['gender'] = TextEditingController(
      text: widget.patient['gender'] ?? '');
  _controllers['birthDate'] = TextEditingController(
      text: widget.patient['birthDate'] ?? '');
  _controllers['snils'] = TextEditingController(
      text: widget.patient['snils'] ?? '');
  _controllers['oms'] = TextEditingController(
      text: widget.patient['oms'] ?? '');
  _controllers['passport'] = TextEditingController(
      text: widget.patient['passport'] ?? '');
  _controllers['phone'] = TextEditingController(
      text: widget.patient['phone'] ?? '');
  _controllers['email'] = TextEditingController(
      text: widget.patient['email'] ?? '');
  _controllers['contraindications'] = TextEditingController(
      text: widget.patient['contraindications'] ?? '');
  
  // Адрес теперь берем из данных пациента
  _controllers['address'] = TextEditingController(
      text: widget.patient['address'] ?? '');
}

  @override
  void dispose() {
    // Очищаем контроллеры
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Медкарта: ${widget.patient['fullName']}'),
        backgroundColor: const Color(0xFF8B8B8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Сохранить изменения' : 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Основная информация
            _buildSection('Основная информация', [
              _buildInfoRow('ФИО', _controllers['fullName']!, 'fullName'),
              _buildInfoRow('Пол', _controllers['gender']!, 'gender'),
              _buildInfoRow('Дата рождения', _controllers['birthDate']!, 'birthDate'),
            ]),
            
            // Документы
            _buildSection('Документы', [
              _buildInfoRow('СНИЛС', _controllers['snils']!, 'snils'),
              _buildInfoRow('Полис ОМС', _controllers['oms']!, 'oms'),
              _buildInfoRow('Паспорт', _controllers['passport']!, 'passport'),
            ]),
            
            // Контактная информация
            _buildSection('Контактная информация', [
              _buildInfoRow('Телефон', _controllers['phone']!, 'phone'),
              _buildInfoRow('Email', _controllers['email']!, 'email'),
              _buildInfoRow('Адрес', TextEditingController(text: widget.patient['address'] ?? ''), 'address'),
            ]),
            
            // Медицинская информация
            _buildSection('Медицинская информация', [
              _buildInfoRow('Противопоказания', _controllers['contraindications']!, 'contraindications', maxLines: 3),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, String field, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: controller,
                    maxLines: maxLines,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (value) {
                      // Обновляем данные при редактировании
                      widget.patient[field] = value;
                    },
                  )
                : Text(
                    controller.text,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      // Сохраняем изменения
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Изменения сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }
}