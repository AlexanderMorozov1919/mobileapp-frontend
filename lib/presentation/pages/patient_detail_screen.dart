import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Добавить эту строку
import 'package:flutter/services.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/section_header.dart'; 
import '../../services/api_client.dart';
import '../../data/models/patient_model.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId; // Изменили на patientId

  const PatientDetailScreen({super.key, required this.patientId}); // Обновили конструктор

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<Patient> _patientFuture;
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  late DateTime _birthDate; // Добавляем для редактирования даты рождения
  Patient? _currentPatient;
  bool _isMale = true; 
  String _docType = 'Паспорт гражданина';

  @override
  void initState() {
    super.initState();
    _patientFuture = _loadPatient().then((patient) {
      setState(() {
        _currentPatient = patient;
        _isMale = patient.isMale;
      });
      return patient;
    });
  }

  Future<Patient> _loadPatient() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    final patient = await apiClient.getMedCardByPatientId(widget.patientId);
    _birthDate = patient.birthDate;
    
    _resetControllers();
    _initControllers(patient);
    
    return patient;
  }

  Future<void> _saveChanges() async {
    if (_currentPatient == null) return;
    
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    try {
      final updatedData = {
        "patient": {
          "id": _currentPatient!.id,
          "last_name": _controllers['lastName']!.text,
          "first_name": _controllers['firstName']!.text,
          "middle_name": _controllers['middleName']!.text,
          "birth_date": DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(
            DateTime.utc(
              _birthDate.year,
              _birthDate.month,
              _birthDate.day,
            ),
          ),
          "is_male": _isMale,
        },
        "personal_info": {
          "passport_series": '${_controllers['passportSeries']!.text} ${_controllers['passportNumber']!.text}',
          "snils": _formatSnils(_controllers['snils']!.text),
          "oms": _formatOms(_controllers['oms']!.text),
        },
        "contact_info": {
          "phone": _controllers['phone']!.text,
          "email": _controllers['email']!.text,
          "address": _controllers['address']!.text,
        },
        "allergy": _controllers['contraindications']!.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => {"name": e})
            .toList(),
      };

      await apiClient.updateMedCard(widget.patientId, updatedData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно обновлены'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Обновляем данные
      setState(() {
        _isEditing = false;
        _patientFuture = _loadPatient().then((patient) {
          _currentPatient = patient;
          return patient;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatSnils(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 11) return digits;
    
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-'
           '${digits.substring(6, 9)} ${digits.substring(9, 11)}';
  }

  // Форматирование ОМС (XXXX XXXX XXXX XXXX)
  String _formatOms(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 16) return digits;
    
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} '
           '${digits.substring(8, 12)} ${digits.substring(12, 16)}';
  }

  void _initControllers(Patient patient) {
    _controllers['lastName'] = TextEditingController(text: patient.lastName);
    _controllers['firstName'] = TextEditingController(text: patient.firstName);
    _controllers['middleName'] = TextEditingController(text: patient.middleName);
    _isMale = patient.isMale;
    _controllers['phone'] = TextEditingController(text: patient.phone);
    _controllers['email'] = TextEditingController(text: patient.email);
    _controllers['address'] = TextEditingController(text: patient.address);
    _controllers['snils'] = TextEditingController(text: patient.snils);
    _controllers['oms'] = TextEditingController(text: patient.oms);
    _controllers['passportSeries'] = TextEditingController(text: patient.passportSeries);
    _controllers['passportNumber'] = TextEditingController(text: patient.passportNumber);
    _controllers['contraindications'] = TextEditingController(
      text: patient.allergies.join(', ')
    );
  }

  void _resetControllers() {
    _controllers.forEach((key, controller) => controller.dispose());
    _controllers.clear();
  }

  Widget _buildGenderField() {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Пол', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _isMale ? 'Мужской' : 'Женский',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                  DropdownMenuItem(value: 'Женский', child: Text('Женский')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _isMale = value == 'Мужской');
                  }
                },
              ),
            ],
          )
        : _buildReadOnlyField('Пол', _isMale ? 'Мужской' : 'Женский');
  }


  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: FutureBuilder<Patient>(
            future: _patientFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text('Медкарта: ${snapshot.data!.fullName}');
              }
              return const Text('Медкарта пациента');
            },
          ),
          backgroundColor: const Color(0xFF5F9EA0),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Сохранить изменения' : 'Редактировать',
            ),
          ],
        ),
        body: FutureBuilder<Patient>(
          future: _patientFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            
            if (!snapshot.hasData) {
              return const Center(child: Text('Данные пациента не найдены'));
            }
            
            final patient = snapshot.data!;
            _currentPatient = patient;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Фамилия и Имя
                    Row(
                      children: [
                        Expanded(child: _buildNameField('Фамилия', 'lastName', patient.lastName, true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildNameField('Имя', 'firstName', patient.firstName, true)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Отчество и Дата рождения
                    Row(
                      children: [
                        Expanded(child: _buildNameField('Отчество', 'middleName', patient.middleName, false)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBirthDateField(patient)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Телефон и СНИЛС
                    Row(
                      children: [
                        Expanded(child: _buildContactField('Телефон', 'phone', patient.phone, true, TextInputType.phone)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDocumentField('СНИЛС', 'snils', _formatSnils(patient.snils), true, [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                          _SnilsFormatter(),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Тип документа и Пол
                    Row(
                      children: [
                        Expanded(child: _buildDocTypeField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildGenderField()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Серия и Номер документа
                    Row(
                      children: [
                        Expanded(child: _buildDocumentField('Серия', 'passportSeries', patient.passportSeries, true, [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDocumentField('Номер', 'passportNumber', patient.passportNumber, true, [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Адрес и Полис
                    Row(
                      children: [
                        Expanded(child: _buildContactField('Адрес', 'address', patient.address, true, null, maxLines: 1)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDocumentField('Полис ОМС', 'oms', _formatOms(patient.oms), true, [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _OmsFormatter(),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildContactField('Email', 'email', patient.email, false, TextInputType.emailAddress),
                    const SizedBox(height: 16),

                    // Аллергии
                    _buildContactField('Аллергии', 'contraindications', patient.allergies.join(', '), false, null, maxLines: 3),
                    const SizedBox(height: 24),

                    // Кнопки (только в режиме редактирования)
                    // if (_isEditing) _buildActionButtons(),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  

  Widget _buildNameField(String label, String key, String value, bool isRequired) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              CustomFormField(
                label: label,
                controller: _controllers[key]!,
                isRequired: isRequired,
                showLabelInside: false,  // Отключаем встроенный label
              ),
            ],
          )
        : _buildReadOnlyField(label, value);
  }


  Widget _buildContactField(String label, String key, String value, bool isRequired, TextInputType? keyboardType, {int maxLines = 1}) {
      return _isEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                CustomFormField(
                  label: label,
                  controller: _controllers[key]!,
                  isRequired: isRequired,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  showLabelInside: false,
                  inputFormatters: label == 'Телефон'
                  ? [
                      // Авто-подстановка "+"
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String text = newValue.text;

                        // Если пользователь стёр + или ввёл без него — добавляем обратно
                        if (!text.startsWith('+')) {
                          text = '+' + text.replaceAll('+', '');
                        }

                        // Ограничение длины до 15 символов
                        if (text.length > 15) {
                          text = text.substring(0, 15);
                        }

                        return TextEditingValue(
                          text: text,
                          selection: TextSelection.collapsed(offset: text.length),
                        );
                      }),
                      FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*')),
                      LengthLimitingTextInputFormatter(15),
                    ]
                  : null,
                ),
              ],
            )
          : _buildReadOnlyField(label, value, maxLines: maxLines);
    }


  Widget _buildDocumentField(String label, String key, String value, bool isRequired, List<TextInputFormatter>? formatters) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              CustomFormField(
                label: label,
                controller: _controllers[key]!,
                isRequired: isRequired,
                inputFormatters: formatters,
                showLabelInside: false,
              ),
            ],
          )
        : _buildReadOnlyField(label, value);
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return SizedBox(
      width: double.infinity, // ⬅️ теперь тянется на всю ширину
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Не указано' : value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDocTypeField() {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Тип документа', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _docType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Паспорт гражданина', child: Text('Паспорт гражданина')),
                  DropdownMenuItem(value: 'Свидетельство о рождении', child: Text('Свидетельство о рождении')),
                  DropdownMenuItem(value: 'Заграничный паспорт', child: Text('Заграничный паспорт')),
                ],
                onChanged: (value) => setState(() => _docType = value!),
              ),
            ],
          )
        : _buildReadOnlyField('Тип документа', _docType);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => setState(() => _isEditing = false),
          child: const Text('Отмена', style: TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B8B8B),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBirthDateField(Patient patient) {
    return _isEditing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Дата рождения', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: Text(DateFormat('dd.MM.yyyy').format(_birthDate)),
                    ),
                  ),
                  DatePickerIconButton(
                    initialDate: _birthDate,
                    onDateSelected: (date) => setState(() => _birthDate = date),
                  ),
                ],
              ),
            ],
          )
        : _buildReadOnlyField('Дата рождения', patient.formattedBirthDate);
  }

  
  // Виджет для полей паспорта
  Widget _buildPassportFields(Patient patient) {
    return _isEditing
        ? Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Серия паспорта', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  CustomFormField(
                    label: 'Серия паспорта',
                    controller: _controllers['passportSeries']!,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    showLabelInside: false,
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Номер паспорта', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  CustomFormField(
                    label: 'Номер паспорта',
                    controller: _controllers['passportNumber']!,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    showLabelInside: false,
                    isRequired: true,
                  ),
                ],
              ),
            ],
          )
        : ListTile(
            title: const Text('Паспорт', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              patient.passportSeries.isNotEmpty && patient.passportNumber.isNotEmpty
                  ? '${patient.passportSeries} ${patient.passportNumber}'
                  : 'Не указан',
            ),
          );
  }


  void _toggleEditMode() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        _saveChanges(); // Вызываем сохранение данных
      }
    } else {
      setState(() => _isEditing = true);
    }
  }
}

// Новые форматтеры для полей
class _SnilsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return newValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '-';
      if (i == 9) formatted += ' ';
      if (i < 11) formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _OmsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return newValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 8 || i == 12) formatted += ' ';
      if (i < 16) formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}