import 'package:flutter/material.dart';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/consultation_screen.dart';

class Appointment {
  final int id;
  final String patientName;
  final String cabinet;
  final DateTime time;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.cabinet,
    required this.time,
    this.status = AppointmentStatus.scheduled,
  });
}

enum AppointmentStatus {
  scheduled,
  completed,
  noShow,
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late final List<DateTime> _dates;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(15, (index) => today.add(Duration(days: index - 7)));
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointments = List.generate(8, (index) {
        final hour = 8 + index;
        return Appointment(
          id: index,
          patientName: _getRandomPatientName(index),
          cabinet: '${201 + index % 3}',
          time: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour),
        );
      });
    });
  }

  String _getRandomPatientName(int index) {
    final names = [
      'Иванов И.И.', 'Петрова А.С.', 'Сидоров Д.К.', 
      'Козлова М.П.', 'Никитин В.А.', 'Фёдорова О.И.',
      'Григорьев П.Д.', 'Семёнова Е.В.'
    ];
    return names[index % names.length];
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
                    appointment.status = AppointmentStatus.noShow;
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
      'id': appointment.id,
      'fullName': appointment.patientName,
      'room': 'Палата ${101 + appointment.id % 5}',
      'diagnosis': 'Диагноз не установлен',
      'gender': appointment.id % 2 == 0 ? 'Мужской' : 'Женский',
      'birthDate': '01.01.${1980 + appointment.id % 20}',
      'snils': '123-456-789 0${appointment.id}',
      'oms': '123456789012345${appointment.id}',
      'passport': '45 06 12345${appointment.id}',
      'address': 'г. Москва, ул. Примерная, д. ${10 + appointment.id}, кв. ${20 + appointment.id}',
      'phone': '+7 (999) 123-45-${appointment.id}',
      'email': 'patient${appointment.id}@example.com',
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
          patientName: appointment.patientName,
          appointmentType: 'appointment',
          recordId: appointment.id,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          appointment.status = AppointmentStatus.completed;
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

    switch (appointment.status) {
      case AppointmentStatus.noShow:
        cardColor = Colors.red.shade100;
        statusIcon = Icons.close;
        iconColor = Colors.red;
        statusText = 'Не явился';
        break;
      case AppointmentStatus.completed:
        cardColor = Colors.green.shade100;
        statusIcon = Icons.check;
        iconColor = Colors.green;
        statusText = 'Приём завершён';
        break;
      case AppointmentStatus.scheduled:
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
                          '${appointment.time.hour}:00',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.time.hour + 1}:00',
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
                          appointment.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Кабинет ${appointment.cabinet}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Плановый осмотр',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (appointment.status != AppointmentStatus.scheduled)
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
          'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
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