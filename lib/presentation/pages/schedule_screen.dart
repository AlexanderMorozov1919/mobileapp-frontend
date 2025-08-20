import 'package:demo_app/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/services/api_client.dart'; // Добавлен импорт
import 'package:demo_app/data/models/appointment_model.dart';
import 'patient_detail_screen.dart';
import 'consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/action_tile.dart';
import '../widgets/date_carousel.dart';
import '../widgets/responsive_card_list.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  late ApiClient _apiClient; // Изменяем на late
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _apiClient = Provider.of<ApiClient>(context, listen: false);
      _isInitialized = true;
      _loadAppointments();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadAppointments() async {
    // Проверяем инициализацию доктора
    if (_apiClient.currentDoctor == null) {
      setState(() {
        _errorMessage = 'Данные доктора не загружены';
        _isLoading = false;
      });
      return;
    }

    // Получаем ID доктора из сохраненных данных
    final doctorId = _apiClient.currentDoctor!.id.toString();

    if (doctorId == null) {
      setState(() {
        _errorMessage = 'ID доктора не установлен';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.getReceptionsHospitalByDoctorAndDate(
        doctorId,
        date: _selectedDate,
        page: 1,
      );

      // Получаем данные из нового пути
      final hits = response['data']['hits'] as List<dynamic>;

      setState(() {
        _appointments = hits.map((hit) {
          final patient = hit['patient'] as Map<String, dynamic>? ?? {};
          final doctor = hit['doctor'] as Map<String, dynamic>? ?? {};
          final birthDate = _parseBirthDate(patient['birth_date']);
          final patientFullName = _buildFullName(patient);
          return Appointment(
            id: hit['id'] ?? 0,
            patientId: patient['id'] ?? 0,
            patientName: patientFullName,
            diagnosis: hit['diagnosis'] ?? 'Диагноз не указан',
            address: _getAddressFromPatient(patient),
            time: _parseDateTime(hit['date']),
            status: _parseStatus(hit['status'] ?? 'scheduled'), // Используем парсинг
            birthDate: birthDate,
            isMale: patient['is_male'] ?? true,
            specialization: doctor['specialization'] ?? 'Терапевт',
          );
        }).toList();
      });
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  String _buildFullName(Map<String, dynamic> person) {
  final lastName = person['last_name'] ?? '';
  final firstName = person['first_name'] ?? '';
  final middleName = person['middle_name'] ?? '';

  // Собираем и убираем лишние пробелы
  return [lastName, firstName, middleName]
      .where((part) => part.isNotEmpty)
      .join(' ');
}

  Future<void> _markAsNoShow(Appointment appointment) async {
    final originalStatus = appointment.status;
    
    // Создаем новый объект с обновленным статусом
    final updatedAppointment = Appointment(
      id: appointment.id,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      diagnosis: appointment.diagnosis,
      address: appointment.address,
      time: appointment.time,
      status: AppointmentStatus.noShow, // Новый статус
      birthDate: appointment.birthDate,
      isMale: appointment.isMale,
      specialization: appointment.specialization,
    );
  
    // Находим индекс старого appointment
    final index = _appointments.indexOf(appointment);
    
    if (index != -1) {
      setState(() {
        _appointments[index] = updatedAppointment;
      });
    }
  
    try {
      await _apiClient.updateReceptionStatus(
        appointment.id,
        status: 'no_show',
      );
    } catch (e) {
      // В случае ошибки возвращаем предыдущий статус
      if (index != -1) {
        setState(() {
          _appointments[index] = appointment;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getAddressFromPatient(Map<String, dynamic> patient) {
    // Временное решение - можно расширить при наличии данных
    return patient['address']?.toString() ?? 
           patient['city']?.toString() ?? 
           'Адрес не указан';
  }

  AppointmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'scheduled':
      default:
        return AppointmentStatus.scheduled;
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      final parsed = DateTime.parse(dateString).toLocal();
      // Проверяем на некорректную дату (0001-01-01)
      if (parsed.year == 1) return DateTime.now();
      return parsed;
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseBirthDate(dynamic birthDate) {
    if (birthDate == null) return DateTime(2000);
    try {
      final parsed = DateTime.parse(birthDate).toLocal();
      if (parsed.year < 1900) return DateTime(2000);
      return parsed;
    } catch (e) {
      return DateTime(2000);
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  void _showAppointmentOptions(dynamic appointmentData) {
    final appointment = appointmentData as Appointment;
    final isCompletedOrNoShow = appointment.status == AppointmentStatus.completed ||
                              appointment.status == AppointmentStatus.noShow;
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 0,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionTile(
                    icon: Icons.person,
                    title: 'Информация о пациенте',
                    onTap: () {
                      Navigator.pop(context);
                      _openPatientDetails(context, appointment);
                    },
                  ),
                  if (!isCompletedOrNoShow) ...[
                    ActionTile(
                      icon: Icons.medical_services,
                      title: 'Начать приём',
                      onTap: () {
                        Navigator.pop(context);
                        _openConsultationScreen(context, appointment);
                      },
                    ),
                    ActionTile(
                      icon: Icons.close,
                      title: 'Отменён',
                      onTap: () {
                        Navigator.pop(context);
                        _markAsNoShow(appointment);
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    child: const Text('Отмена', 
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPatientDetails(BuildContext context, Appointment appointment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patientId: appointment.patientId.toString(),
        ),
      ),
    );

    // Обновляем список после возвращения
    _loadAppointments();
  }

  void _openConsultationScreen(BuildContext context, Appointment appointment) {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    final doctorId = apiClient.currentDoctorId?.toString() ?? '0';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: appointment.patientName,
          appointmentType: 'appointment',
          recordId: appointment.id,
          doctorId: int.parse(doctorId), // Добавляем doctorId
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Расписание приёмов',
          style: TextStyle(color: Color(0xFF8B8B8B)),
        ),
        leading: IconButton( // ← Кнопка выхода слева
        icon: const Icon(Icons.logout, color: Color(0xFF8B8B8B)),
        tooltip: 'Выйти',
        onPressed: () {
          // Чистим данные и выходим
          Provider.of<ApiClient>(context, listen: false).logout();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
        actions: [
          DatePickerIconButton(
            initialDate: _selectedDate,
            onDateSelected: _handleDateSelected,
            tooltip: 'Выбрать дату расписания',
          ),
        ],
      ),
      body: Column(
        children: [
          DateCarousel(
            initialDate: _selectedDate,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
              _loadAppointments();
            },
            daysRange: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Ошибка: $_errorMessage'))
                    : ResponsiveCardList(
                        type: CardListType.schedule,
                        items: _appointments,
                        onItemTap: (context, item) => _showAppointmentOptions(item),
                        onRefresh: _refreshAppointments,
                      ),
          ),
        ],
      ),
    );
  }

}