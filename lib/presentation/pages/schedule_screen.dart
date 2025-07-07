import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demo_app/data/models/appointment_model.dart';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/consultation_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _dates;
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Форматируем дату в строку для запроса: "гггг-мм-дд"
  String _formatDateForRequest(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Форматируем время: "чч:мм"
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Форматируем дату для отображения: "дд.мм.гггг"
  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(15, (index) => today.add(Duration(days: index - 7)));
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final formattedDate = _formatDateForRequest(_selectedDate);
    final url = 'http://192.168.30.106:8080/main/1?date=$formattedDate&page=1';
    
    print("Запрос к URL: $url");
    
    final response = await http.get(Uri.parse(url));

    print("Статус ответа: ${response.statusCode}");
    print("Тело ответа: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("Получено ${jsonData.length} записей");
      
      setState(() {
        _appointments = Appointment.fromJsonList(jsonData);
        // В методе _loadAppointments после получения данных
        print("Записи после парсинга:");
        for (var app in _appointments) {
          print("ID: ${app.id}, Дата: ${app.date}, Статус: ${app.status}");
        }
      });
    } else {
      setState(() {
        _errorMessage = 'Ошибка сервера: ${response.statusCode}';
      });
    }
  } catch (e) {
    print("Ошибка: $e");
    setState(() {
      _errorMessage = 'Ошибка сети: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showAppointmentOptions(BuildContext context, Appointment appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Информация о пациенте'),
                onTap: () {
                  Navigator.pop(context);
                  _openPatientDetails(context, appointment);
                },
              ),
              if (appointment.status == 'scheduled')
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Начать приём'),
                  onTap: () {
                    Navigator.pop(context);
                    _openConsultationScreen(context, appointment);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Не явился'),
                onTap: () {
                  setState(() {
                    appointment.status = 'cancelled';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPatientDetails(BuildContext context, Appointment appointment) {
    final patient = {
      'id': appointment.patientId,
      'fullName': 'Пациент ID: ${appointment.patientId}',
      'room': 'Палата ${101 + appointment.patientId % 5}',
      'diagnosis': appointment.diagnosis ?? 'Диагноз не установлен',
      'gender': appointment.patientId % 2 == 0 ? 'Мужской' : 'Женский',
      'birthDate': '01.01.${1980 + appointment.patientId % 20}',
      'snils': '123-456-789 0${appointment.patientId}',
      'oms': '123456789012345${appointment.patientId}',
      'passport': '45 06 12345${appointment.patientId}',
      'address': appointment.address,
      'phone': '+7 (999) 123-45-${appointment.patientId}',
      'email': 'patient${appointment.patientId}@example.com',
      'contraindications': 'Нет',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _openConsultationScreen(BuildContext context, Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: 'Пациент ID: ${appointment.patientId}',
          appointmentType: 'appointment',
          recordId: appointment.id,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          appointment.status = 'completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заключение врача сохранено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Widget _buildTimeSlot(Appointment appointment) {
    Color? cardColor;
    IconData? statusIcon;
    Color? iconColor;
    String statusText = '';

    print("Построение карточки для приёма ID: ${appointment.id}");

    switch (appointment.status) {
      case 'cancelled':
        cardColor = Colors.red.shade100;
        statusIcon = Icons.close;
        iconColor = Colors.red.shade800;
        statusText = 'Не явился';
        break;
      case 'completed':
        cardColor = Colors.green.shade100;
        statusIcon = Icons.check;
        iconColor = Colors.green;
        statusText = 'Приём завершён';
        break;
      case 'scheduled':
      default:
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: InkWell(
        onTap: () => _showAppointmentOptions(context, appointment),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(appointment.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(appointment.date.add(const Duration(hours: 1))),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 20, thickness: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Пациент ID: ${appointment.patientId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          appointment.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (appointment.diagnosis != null && appointment.diagnosis!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Диагноз: ${appointment.diagnosis}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (appointment.status != 'scheduled')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Icon(statusIcon, color: iconColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Пн';
      case 2: return 'Вт';
      case 3: return 'Ср';
      case 4: return 'Чт';
      case 5: return 'Пт';
      case 6: return 'Сб';
      case 7: return 'Вс';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = date == _selectedDate;
              final dayName = _getDayName(date.weekday);
              final isToday = date.day == DateTime.now().day && 
                              date.month == DateTime.now().month &&
                              date.year == DateTime.now().year;
              
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = date;
                  _loadAppointments();
                }),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : isToday
                        ? const Color(0xFFD2B48C).withOpacity(0.3)
                        : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                    border: isToday
                      ? Border.all(color: const Color(0xFFD2B48C), width: 2)
                      : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Расписание на ${_formatDateForDisplay(_selectedDate)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage.isNotEmpty)
          Expanded(
            child: Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (_appointments.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'На выбранную дату приёмов не запланировано',
                style: TextStyle(fontSize: 16),
            ),
          )
          )
        else 
          Expanded(
            child: ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                return _buildTimeSlot(_appointments[index]);
              },
            ),
          ),
      ],
    );
  }
}