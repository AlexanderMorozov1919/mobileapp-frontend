import 'package:demo_app/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import './call_detail_screen.dart';
import '../widgets/responsive_card_list.dart';
import '../widgets/date_carousel.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _filteredCalls = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _refreshCalls() async {
    await _loadCalls();
  }

  Future<void> _loadCalls() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final currentDoctor = apiClient.currentDoctor;

      if (currentDoctor == null) {
        throw Exception('Доктор не авторизован');
      }

      final docId = currentDoctor.id.toString();

      // Получаем список вызовов по дате и доктору
      final callsResponse = await apiClient.getEmergencyCallsByDoctorAndDate(
        docId,
        date: _selectedDate,
      );

      final callsData = callsResponse['hits'] as List<dynamic>?;

      if (callsData == null) {
        throw Exception('Получен некорректный ответ от сервера (вызовы)');
      }

      // Преобразуем вызовы в нужный формат (статус изначально "Выполняется")
      List<Map<String, dynamic>> loadedCalls = callsData.map((call) {
        final createdAt = DateTime.parse(call['created_at']).toLocal();
        final timeStr = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

        return {
          'id': call['id'],
          'date': createdAt,
          'address': call['address'] ?? 'Адрес не указан',
          'phone': call['phone'] ?? 'Телефон не указан',
          'emergency': call['emergency'] ?? false,
          'mainStatus': call['emergency'] == true ? 'ЭКСТРЕННЫЙ' : 'НЕОТЛОЖНЫЙ',
          'executionStatus': 'Выполняется',
          'time': timeStr,
          'patients': <Map<String, dynamic>>[],
          'isCompleted': false,
        };
      }).toList();

      // Параллельно загружаем пациентов для каждого вызова и обновляем статус
      final futures = loadedCalls.map((call) async {
        try {
          final patientsResponse = await apiClient.getEmergencyCallDetails(call['id'].toString());
          final patientsList = (patientsResponse['data']?['hits'] as List<dynamic>?) ?? [];

          final patients = patientsList.map((patientData) {
            final patient = patientData['patient'];
            final diagnosis = patientData['diagnosis'] as String? ?? '';

            return {
              'id': patient['id'],
              'name': '${patient['last_name']} ${patient['first_name']}',
              'hasConclusion': diagnosis.trim().isNotEmpty,
            };
          }).toList();

          call['patients'] = patients;

          final completedCount = patients.where((p) => p['hasConclusion'] == true).length;
          call['isCompleted'] = patients.isNotEmpty && (completedCount == patients.length);
          call['executionStatus'] = call['isCompleted'] ? 'Завершён' : 'Выполняется';
        } catch (e) {
          call['patients'] = <Map<String, dynamic>>[];
          call['isCompleted'] = false;
          call['executionStatus'] = 'Выполняется';
          print('Ошибка при загрузке пациентов для вызова ${call['id']}: $e');
        }
      });

      await Future.wait(futures);

      setState(() {
        _calls = loadedCalls;
        _filterCallsByDate(); // Обновляем фильтрованные вызовы
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки вызовов: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  List<Map<String, dynamic>> _transformApiData(List<dynamic> apiData) {
    return apiData.map((call) {
      final createdAt = DateTime.parse(call['created_at']);
      final time = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      final status = call['emergency'] == true ? 'ЭКСТРЕННЫЙ' : 'НЕОТЛОЖНЫЙ';
  
      return {
        'id': call['id'],
        'date': createdAt,
        'address': call['address'] ?? 'Адрес не указан',
        'phone': call['phone'] ?? 'Телефон не указан',
        'status': status,
        'time': time,
        'isCompleted': false,
        'patients': [],
      };
    }).toList();
  }

List<Map<String, dynamic>> _getPatientsFromCall(Map<String, dynamic> call) {
  // Временное решение, пока нет данных о пациентах
  return [
    {
      'id': call['id'], // Используем ID вызова как временный ID пациента
      'name': 'Пациент: ${call['phone']}',
      'hasConclusion': false,
    }
  ];
}

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterCallsByDate();
    });
  }

  void _filterCallsByDate() {
    _filteredCalls = _calls.where((call) {
      final callDate = call['date'] as DateTime;
      return callDate.year == _selectedDate.year &&
            callDate.month == _selectedDate.month &&
            callDate.day == _selectedDate.day;
    }).toList();

    _filteredCalls.sort((a, b) {
      // Завершённые вниз
      
      final aCompleted = a['executionStatus'] == 'Завершён';
      final bCompleted = b['executionStatus'] == 'Завершён';
      if (aCompleted && !bCompleted) return 1;
      if (!aCompleted && bCompleted) return -1;

      // Сначала экстренные
      final aEmergency = a['mainStatus'] == 'ЭКСТРЕННЫЙ';
      final bEmergency = b['mainStatus'] == 'ЭКСТРЕННЫЙ';
      if (aEmergency && !bEmergency) return -1;
      if (!aEmergency && bEmergency) return 1;

      // Потом сортировка по времени
      final aTime = a['date'] as DateTime;
      final bTime = b['date'] as DateTime;
      return aTime.compareTo(bTime);
    });
  }


  void _openCallDetails(dynamic callData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallDetailScreen(call: callData as Map<String, dynamic>),
      ),
    ).then((_) {
      _updateCallStatusIfAllPatientsHaveConclusion(callData);
      setState(() {});
    });
  }

  void _updateCallStatusIfAllPatientsHaveConclusion(Map<String, dynamic> call) {
  final patients = call['patients'] as List<Map<String, dynamic>>? ?? [];

  final callIndex = _calls.indexWhere((c) => c['id'] == call['id']);
  final filteredIndex = _filteredCalls.indexWhere((c) => c['id'] == call['id']);

  if (patients.isNotEmpty && patients.every((p) => p['hasConclusion'] == true)) {
    setState(() {
      if (callIndex != -1) _calls[callIndex]['status'] = 'Завершён';
      if (filteredIndex != -1) _filteredCalls[filteredIndex]['status'] = 'Завершён';
    });
  } else {
    final currentStatus = call['status'] ?? 'Выполняется';
    setState(() {
      if (callIndex != -1) _calls[callIndex]['status'] = currentStatus;
      if (filteredIndex != -1) _filteredCalls[filteredIndex]['status'] = currentStatus;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Вызовы',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCalls,
            tooltip: 'Обновить список',
            color: const Color(0xFF8B8B8B),
          ),
        ],
      ),
      body: Column(
        children: [
          DateCarousel(
            initialDate: _selectedDate,
            onDateSelected: _handleDateSelected,
            daysRange: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Вызовы на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }


Widget _buildContent() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (_errorMessage != null) {
    return Center(child: Text(_errorMessage!));
  }
  
  if (_filteredCalls.isEmpty) {
    return const Center(child: Text('Нет вызовов на выбранную дату'));
  }
  
  return ResponsiveCardList(
    type: CardListType.calls,
    items: _filteredCalls,
    onItemTap: (context, item) => _openCallDetails(item),
    onRefresh: _refreshCalls,
  );
}
}