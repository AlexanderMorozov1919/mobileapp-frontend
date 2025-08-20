import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_form_field.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  String? _gender;
  DateTime? _birthDate;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить пациента'),
        backgroundColor: const Color(0xFF8B8B8B),
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
              // Фамилия
              CustomFormField(
                label: 'Фамилия*',
                controller: _lastNameController,
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Имя
              CustomFormField(
                label: 'Имя*',
                controller: _firstNameController,
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Отчество
              CustomFormField(
                label: 'Отчество*',
                controller: _middleNameController,
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // Пол
              _buildGenderDropdown(),
              const SizedBox(height: 20),

              // Дата рождения
              Row(
                children: [
                  const Text(
                    'Дата рождения*',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(width: 20),
                  DatePickerIconButton(
                    initialDate: _birthDate,
                    onDateSelected: (date) => setState(() => _birthDate = date),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _birthDate != null
                          ? DateFormat('dd.MM.yyyy').format(_birthDate!)
                          : 'Не выбрана',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Кнопки
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

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: 'Пол*',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
        DropdownMenuItem(value: 'Женский', child: Text('Женский')),
      ],
      onChanged: (value) => setState(() => _gender = value),
      validator: (value) => value == null ? 'Выберите пол' : null,
    );
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выберите дату рождения'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final patientData = {
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'birthDate': DateFormat('yyyy-MM-dd').format(_birthDate!),
        'gender': _gender!,
      };

      Navigator.pop(context, patientData);
    }
  }
}