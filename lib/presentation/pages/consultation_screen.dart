// pages/consultation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../data/models/dynamic_field_model.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientName;
  final String appointmentType;
  final int recordId;
  final int doctorId;
  final int? emergencyCallId; // Добавляем новый параметр
  final bool isReadOnly;

  const ConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentType,
    required this.recordId,
    required this.doctorId,
    this.emergencyCallId, // Делаем необязательным
    this.isReadOnly = false,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final Map<String, dynamic> _formValues = {};
  List<DynamicField> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _documentType;
  String? _documentTypeKey;
  List<Map<String, dynamic>> _medServices = [];
  final _formKey = GlobalKey<FormState>();
  static const Map<String, List<String>> mainFieldsMap = {
    'traumatologist_data': [
      'injury_type',
      'localization',
      'fracture',
      'dislocation',
      'sprain',
      'contusion',
      'treatment_plan',
    ],
    'neurologist_data': [
      'diagnosis',
      'complaints',
      'recommendations',
      'sensitivity',
      'gait',
      'speech',
    ],
    'urologist_data': [
      'complaints',
      'diagnosis',
      'treatment',
    ],
    'allergologist_data': [
      'complaints',
      'allergen_history',
      // 'ige_level',
      // 'immunotherapy',
      'diagnosis',
      'recommendations',
    ],
    'psychiatrist_data': [
      'mental_status',
      'mood',
      'thought_process',
      'diagnosis_icd',
      'therapy_plan',
    ],
    'proctologist_data': [
      'complaints',
      'digital_examination',
      'hemorrhoids',
      'diagnosis',
      'recommendations',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  Future<void> _completeEmergencyConsultation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return;
    }
    if ((_formValues['diagnosis'] == null || (_formValues['diagnosis'] as String).trim().isEmpty) ||
      (_formValues['recommendations'] == null || (_formValues['recommendations'] as String).trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Диагноз и рекомендации должны быть заполнены')),
        );
        return;
    }

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);

      // Подготавливаем данные для отправки
      final Map<String, dynamic> specializationUpdates = {};
      for (var field in _fields) {
        specializationUpdates[field.name] = _formValues[field.name];
      }

      // Рассчитываем общую стоимость
      final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));

      // Отправляем данные
      await apiClient.updateEmergencyReception(
        receptionId: widget.recordId,
        diagnosis: _formValues['diagnosis'] ?? '',
        recommendations: _formValues['recommendations'] ?? '',
        specializationUpdates: specializationUpdates,
        medServices: _medServices,
        totalCost: totalCost,
      );

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заключение успешно обновлено!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadConsultationData() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      Map<String, dynamic> response;

      if (widget.appointmentType == 'emergency') {
        response = await apiClient.getEmergencyConsultationData(
          widget.emergencyCallId.toString(),
          widget.recordId.toString(),
          // widget.emergencyCallId.toString(),
        );
      } else {
        response = await apiClient.getReceptionDetails(
          widget.doctorId.toString(),
          widget.recordId.toString(),
        );
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
    
    // Получаем медицинские услуги
      final List<dynamic> medServices = data['med_services'] as List<dynamic>? ?? [];
      final List<Map<String, dynamic>> medServicesList = medServices.map<Map<String, dynamic>>((service) {
        return {
          'id': service['id'] as int,
          'name': service['name'] as String,
          'price': service['price'] as int,
        };
      }).toList();
  
      setState(() {
        final doctor = data['doctor'] as Map<String, dynamic>? ?? {};
        _documentType = doctor['specialization'] as String? ?? data['specialization'] as String?;
        final specData = data['specialization_data'] as Map<String, dynamic>? ?? {};
        _documentTypeKey = specData['document_type'] as String? ?? 'unknown';
        final fields = specData['fields'] as List<dynamic>? ?? [];
        _fields = fields.map((f) => DynamicField.fromJson(f as Map<String, dynamic>)).toList();
        _medServices = medServicesList;

        // Инициализируем значения формыё
        for (var field in _fields) {
            _formValues[field.name] = field.value ?? field.defaultValue ?? _getDefaultForType(field.type);
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  dynamic _getDefaultForType(String type) {
    switch (type) {
      case 'boolean': return false;
      case 'int': return 0;
      case 'array': return [];
      case 'object': return {};
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Консультация: ${widget.patientName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildDynamicForm(),
    );
  }

  Map<String, List<DynamicField>> splitFields(List<DynamicField> fields, String? documentType) {
    final mainFieldNames = mainFieldsMap[documentType] ?? [];

    final mainFields = <DynamicField>[];
    final additionalFields = <DynamicField>[];

    for (var field in fields) {
      if (mainFieldNames.contains(field.name)) {
        mainFields.add(field);
      } else {
        additionalFields.add(field);
      }
    }

    return {
      'main': mainFields,
      'additional': additionalFields,
    };
  }


  Widget _buildMedServicesSection() {
    if (_medServices.isEmpty) {
      return const SizedBox(); // Не отображать если услуг нет
    }

    // Вычисляем итоговую стоимость
    final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Медицинские услуги',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Список услуг
        ..._medServices.map((service) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.medical_information, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        service['name'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${service['price']} руб.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Разделитель
        const Divider(height: 30, thickness: 1.5, color: Colors.grey),

        // Итоговая стоимость
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Общая стоимость:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '$totalCost руб.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicForm() {
    final split = splitFields(_fields, _documentTypeKey);
    final mainFields = split['main']!;
    final additionalFields = split['additional']!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,  // Вот тут обязательно передай ключ
        child: Column(
          children: [
            Text(
              'Специализация: ${_documentType ?? 'Неизвестно'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Левая колонка - основные поля
                  Expanded(
                    child: ListView(
                      children: mainFields.map((field) => _buildField(field)).toList(),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Правая колонка - дополнительные поля
                  Expanded(
                    child: ListView(
                      children: additionalFields.map((field) => _buildField(field)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            _buildMedServicesSection(),
            const SizedBox(height: 20),
            
            // Кнопка по центру снизу
            if (!widget.isReadOnly)
              SizedBox(
                width: 250, // фиксированная ширина кнопки
                child: ElevatedButton(
                  onPressed: _completeConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Завершить консультацию',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }




  Widget _buildField(DynamicField field) {
    // print('isReadOnly: ${widget.isReadOnly}');
    // print('Field.Name: ${field.name} Field.Type ${field.type}');
    switch (field.type) {
      case 'string':
      case 'text':
        return _buildTextField(field);
      case 'int':
      case 'number':
        return _buildNumberField(field);
      case 'boolean':
        return _buildBooleanField(field);
      case 'array':
        return _buildArrayField(field);
      case 'object':
        return _buildObjectField(field);
      default:
        return Text('Неизвестный тип поля: ${field.type}');
    }
  }

  Widget _buildBooleanField(DynamicField field) {
    final currentValue = _formValues[field.name] as bool? ?? false;

    if (widget.isReadOnly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Icon(
              currentValue ? Icons.check_circle : Icons.cancel,
              color: currentValue ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              '${field.description}: ${currentValue ? 'Да' : 'Нет'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(field.description, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Switch(
            value: currentValue,
            onChanged: (value) {
              setState(() {
                _formValues[field.name] = value;
              });
            },
          ),
        ],
      ),
    );
  }


  Widget _buildTextField(DynamicField field) {
    final value = (_formValues[field.name] ?? _getDefaultForType(field.type)).toString();
    // Режим только для чтения - всегда используем текстовое представление
    if (widget.isReadOnly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Режим редактирования - используем StatefulBuilder для управления состоянием
    return StatefulBuilder(
      builder: (context, setStateField) {
        final controller = TextEditingController(text: value);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller,
                maxLines: field.format == 'longtext' ? 5 : 1,
                maxLength: field.maxLength,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.example != null 
                      ? 'Пример: ${field.example}'
                      : 'Введите ${field.description.toLowerCase()}',
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.clear();
                            _formValues[field.name] = '';
                            setStateField(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _formValues[field.name] = value;
                },
                validator: (value) {
                  if (field.required && (value == null || value.isEmpty)) {
                    return 'Обязательное поле';
                  }
                  if (field.minLength != null && (value?.length ?? 0) < field.minLength!) {
                    return 'Минимум ${field.minLength} символов';
                  }
                  return null;
                },
              ),
              if (field.valueFormat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    field.valueFormat!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  
  Widget _buildNumberField(DynamicField field) {
    final value = _formValues[field.name]?.toString() ?? '';
    final controller = TextEditingController(text: value);

    if (widget.isReadOnly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.description, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: field.maxLength,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: field.example != null
                  ? 'Пример: ${field.example}'
                  : 'Введите ${field.description.toLowerCase()}',
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        controller.clear();
                        _formValues[field.name] = '';
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _formValues[field.name] = value;
            },
            validator: (value) {
              if (field.required && (value == null || value.isEmpty)) {
                return 'Обязательное поле';
              }
              if (value != null && int.tryParse(value) == null) {
                return 'Введите число';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }


  Widget _buildArrayField(DynamicField field) {
    final rawItems = _formValues[field.name] ?? [];
    final items = (rawItems is List) ? rawItems : [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Нет элементов', style: TextStyle(color: Colors.grey)),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              String displayText;
              if (item is Map) {
                // превращаем объект в строку типа "allergen: пыльца, reaction: +"
                displayText = item.entries.map((e) => "${e.key}: ${e.value}").join(", ");
              } else {
                displayText = item.toString();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text('• $displayText')),
                    if (!widget.isReadOnly)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            items.removeAt(index);
                            _formValues[field.name] = items;
                          });
                        },
                      ),
                  ],
                ),
              );
            }).toList(),

          const SizedBox(height: 10),
          if (!widget.isReadOnly) _buildArrayItemAdder(field, items.cast<String>()),
        ],
      ),
    );
  }


  Widget _buildArrayItemAdder(DynamicField field, List<String> items) {
    if (widget.isReadOnly) return const SizedBox(); // полностью скрываем

    final controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Новый элемент',
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                items.add(controller.text);
                _formValues[field.name] = items;
                controller.clear();
              });
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }


  Widget _buildObjectField(DynamicField field) {
    final Map<String, dynamic> objectData =
        Map<String, dynamic>.from(_formValues[field.name] ?? {});

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          if (objectData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Нет элементов', style: TextStyle(color: Colors.grey)),
            )
          else
            ...objectData.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text('$key: $value')),
                    if (!widget.isReadOnly)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            objectData.remove(key);
                            _formValues[field.name] = objectData;
                          });
                        },
                      ),
                  ],
                ),
              );
            }).toList(),

          const SizedBox(height: 10),
          if (!widget.isReadOnly) _buildObjectItemAdder(field, objectData),
        ],
      ),
    );
  }

  Widget _buildObjectItemAdder(DynamicField field, Map<String, dynamic> objectData) {
    if (widget.isReadOnly) return const SizedBox(); // полностью скрываем

    final keyController = TextEditingController();
    final valueController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Добавить элемент:',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.keyFormat ?? 'Ключ',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: valueController,
                keyboardType: field.format == 'map[string]int'
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.valueFormat ?? 'Значение',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final key = keyController.text.trim();
                final value = valueController.text.trim();

                if (key.isNotEmpty && value.isNotEmpty) {
                  setState(() {
                    objectData[key] = field.format == 'map[string]int'
                        ? int.tryParse(value) ?? 0
                        : value;
                    _formValues[field.name] = objectData;
                    keyController.clear();
                    valueController.clear();
                  });
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> _completeConsultation() async {
    if (widget.appointmentType == 'emergency') {
      await _completeEmergencyConsultation();
    } else {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
        );
        return;
      }

      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);

        // Формируем данные для отправки
        final specializationData = {
          'document_type': _documentTypeKey,
          'fields': _fields.map((field) {
            return {
              'name': field.name,
              'type': field.type,
              'description': field.description,
              'format': field.format,
              'min_length': field.minLength,
              'max_length': field.maxLength,
              'min_value': field.minValue,
              'max_value': field.maxValue,
              'min_items': field.minItems,
              'max_items': field.maxItems,
              'example': field.example,
              'default_value': field.defaultValue,
              'value': _formValues[field.name],
              'key_format': field.keyFormat,
              'value_format': field.valueFormat,
            };
          }).toList(),
        };

        await apiClient.updateReceptionHospital(
          widget.recordId.toString(),
          {
            'diagnosis': _formValues['diagnosis'] ?? '',
            'recommendations': _formValues['recommendations'] ?? '',
            'status': 'completed',
            'specialization_data': specializationData,
          },
        );

        if (!mounted) return;
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Консультация успешно завершена!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } 
}