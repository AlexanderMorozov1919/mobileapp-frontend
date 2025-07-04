import 'package:flutter/material.dart';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';

// Модель данных для приёма
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

// Статусы приёма
enum AppointmentStatus {
  scheduled,  // Запланирован
  completed,  // Приём завершен
  noShow,     // Не явился
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
  Map<int, AppointmentStatus> _appointmentStatus = {};

  @override
  void initState() {
    super.initState();
    // Генерация дат: 7 дней назад и 7 дней вперед
    final today = DateTime.now();
    _dates = List.generate(15, (index) => today.add(Duration(days: index - 7)));
    _loadAppointments();
  }

  // Загрузка фиктивных данных приёмов
  void _loadAppointments() {
    _appointments = List.generate(8, (index) {
      final hour = 8 + index;
      return Appointment(
        id: index,
        patientName: _getRandomPatientName(index),
        cabinet: '${201 + index % 3}',
        time: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour),
      );
    });
  }

  // Генерация случайного имени пациента
  String _getRandomPatientName(int index) {
    final names = [
      'Иванов И.И.', 'Петрова А.С.', 'Сидоров Д.К.', 
      'Козлова М.П.', 'Никитин В.А.', 'Фёдорова О.И.',
      'Григорьев П.Д.', 'Семёнова Е.В.'
    ];
    return names[index % names.length];
  }

  // Показ опций для приёма
  void _showAppointmentOptions(BuildContext context, int appointmentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text('Информация о пациенте', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _openPatientDetails(context, appointmentId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.green),
                title: const Text('Начать приём', style: TextStyle(fontSize: 16)),
                onTap: () {
                  setState(() {
                    _appointmentStatus[appointmentId] = AppointmentStatus.completed;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Приём пациента ${_appointments.firstWhere((a) => a.id == appointmentId).patientName} начат'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Не явился', style: TextStyle(fontSize: 16)),
                onTap: () {
                  setState(() {
                    _appointmentStatus[appointmentId] = AppointmentStatus.noShow;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Открытие медкарты пациента
  void _openPatientDetails(BuildContext context, int appointmentId) {
    // Фиктивные данные пациента для демонстрации
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    final patient = {
      'id': appointmentId,
      'fullName': appointment.patientName,
      'room': 'Палата ${101 + appointmentId % 5}',
      'diagnosis': 'Диагноз не установлен',
      'gender': appointmentId % 2 == 0 ? 'Мужской' : 'Женский',
      'birthDate': '01.01.${1980 + appointmentId % 20}',
      'snils': '123-456-789 0$appointmentId',
      'oms': '123456789012345$appointmentId',
      'passport': '45 06 12345$appointmentId',
      'address': 'г. Москва, ул. Примерная, д. ${10 + appointmentId}, кв. ${20 + appointmentId}',
      'phone': '+7 (999) 123-45-${appointmentId}',
      'email': 'patient$appointmentId@example.com',
      'contraindications': 'Нет',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  // Построение карточки приёма
  Widget _buildTimeSlot(Appointment appointment) {
    final status = _appointmentStatus[appointment.id] ?? AppointmentStatus.scheduled;
    Color? cardColor;
    IconData? statusIcon;
    Color? iconColor;
    String statusText = '';

    // Определение стилей в зависимости от статуса
    if (status == AppointmentStatus.noShow) {
      cardColor = Colors.red.shade100;
      statusIcon = Icons.close;
      iconColor = Colors.red.shade800;
      statusText = 'Не явился';
    } else if (status == AppointmentStatus.completed) {
      cardColor = Colors.grey.shade300;
      statusIcon = Icons.check;
      iconColor = Colors.green;
      statusText = 'Приём завершён';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: InkWell(
        onTap: () => _showAppointmentOptions(context, appointment.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Row(
                children: [
                  // Временной интервал
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
                  
                  // Вертикальный разделитель
                  const VerticalDivider(width: 20, thickness: 1),
                  
                  // Детали приема
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
              // Иконка и текст статуса
              if (status != AppointmentStatus.scheduled)
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
  
  // Преобразование номера дня недели в название
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
        // Карусель с датами
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
        
        // Заголовок с выбранной датой
        Text(
          'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 20),
        
        // Список приёмов
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