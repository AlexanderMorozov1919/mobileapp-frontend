import 'package:flutter/material.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _patientData = {
    'fullName': '',
    'gender': '',
    'passportSeries': '',
    'passportNumber': '',
    'snils': '',
    'oms': '',
    'address': '',
    'phone': '',
    'email': '',
    'contraindications': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить пациента'),
        backgroundColor: const Color(0xFF8B8B8B), // Серый
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ФИО
              _buildTextField('ФИО', 'fullName', isRequired: true),
              
              // Пол
              _buildGenderDropdown(),
              
              // Паспортные данные
              const SizedBox(height: 10),
              const Text('Паспортные данные', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Серия', 'passportSeries', maxLength: 4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('Номер', 'passportNumber', maxLength: 6),
                  ),
                ],
              ),
              
              // СНИЛС
              _buildTextField('СНИЛС', 'snils'),
              
              // ОМС
              _buildTextField('Полис ОМС', 'oms'),
              
              // Адрес
              _buildTextField('Адрес проживания', 'address'),
              
              // Контактная информация
              const SizedBox(height: 10),
              const Text('Контактная информация', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              _buildTextField('Номер телефона', 'phone', keyboardType: TextInputType.phone),
              _buildTextField('Электронная почта', 'email', keyboardType: TextInputType.emailAddress),
              
              // Противопоказания
              const SizedBox(height: 10),
              _buildTextField('Противопоказания', 'contraindications', maxLines: 3),
              
              // Кнопки
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _savePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B8B8B),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String field, {
    bool isRequired = false,
    int? maxLength,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Обязательное поле';
          }
          return null;
        },
        onSaved: (value) => _patientData[field] = value ?? '',
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Пол',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
          DropdownMenuItem(value: 'Женский', child: Text('Женский')),
        ],
        onChanged: (value) => _patientData['gender'] = value ?? '',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Выберите пол';
          }
          return null;
        },
      ),
    );
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // В реальном приложении здесь будет сохранение в базу данных
      // Сейчас просто показываем сообщение и закрываем экран
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новый пациент успешно зарегистрирован'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Закрываем экран
      Navigator.pop(context);
    }
  }
}