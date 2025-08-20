import 'package:demo_app/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/services/api_client.dart'; // Добавлен импорт
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/patient_history_screen.dart';
import 'package:demo_app/presentation/pages/add_patient_screen.dart';
import '../widgets/responsive_card_list.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
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
      _fetchPatients();
    }
  }

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _patients;
    
    return _patients.where((patient) {
      final fullName = _buildFullName(patient).toLowerCase();
      return fullName.contains(query);
    }).toList();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  
    try {
      if (_apiClient.currentDoctor == null) {
        throw Exception('Данные доктора не загружены');
      }
      
      final docId = _apiClient.currentDoctor!.id.toString();
      final patientsData = await _apiClient.getAllPatients(docId);
      
      setState(() {
        _patients = patientsData.map((patient) {
          return {
            'id': patient['id'] ?? patient['ID'] ?? 0, // Универсальное получение ID
            'first_name': patient['first_name'] ?? '',
            'last_name': patient['last_name'] ?? '',
            'middle_name': patient['middle_name'] ?? '',
            'is_male': patient['is_male'] ?? false,
            'birth_date': patient['birth_date'] ?? '',
          };
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

  Future<void> _refreshPatients() async {
    await _fetchPatients();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addNewPatient(Map<String, dynamic> patientData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Формируем данные в соответствии с требуемой структурой
      final patientPayload = {
        'first_name': patientData['firstName'],
        'last_name': patientData['lastName'],
        'middle_name': patientData['middleName'],
        'birth_date': patientData['birthDate'],
        'is_male': patientData['gender'] == 'Мужской',
      };

      await _apiClient.createPatient(patientPayload);
      await _fetchPatients();
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка добавления: ${e.message}';
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

  void _openPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patientId: patient['id'].toString(), // Преобразуем ID в строку
        ),
      ),
    );
  }

  void _openPatientHistory(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHistoryScreen(
          patientId: patient['id'],
          patientName: _buildFullName(patient), // Исправлено на snake_case
        ),
      ),
    );
  }

String _buildFullName(Map<String, dynamic> patient) {
  final lastName = patient['last_name'] ?? '';
  final firstName = patient['first_name'] ?? '';
  final middleName = patient['middle_name'] ?? '';
  return '$lastName $firstName $middleName'.trim();
}

  void _openAddPatientScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    ).then((result) {
      if (result != null) {
        _addNewPatient(result);
      }
    });
  }

 @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && _errorMessage!.contains('Данные доктора не загружены')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Данные доктора не загружены'),
            ElevatedButton(
              onPressed: _fetchPatients,
              child: const Text('Повторить попытку'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Пациенты',
          style: TextStyle(color: Color(0xFF8B8B8B)),
          ), // упрощенный заголовок
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 60, // уменьшенная высота
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
            icon: const Icon(Icons.refresh, color: Color(0xFF8B8B8B)), // Серый цвет
            onPressed: _refreshPatients,
            tooltip: 'Обновить список',
          ),
          // IconButton(
          //   icon: const Icon(Icons.add, color: Color(0xFF8B8B8B)), // Серый цвет
          //   onPressed: _openAddPatientScreen,
          //   tooltip: 'Добавить пациента',
          // ),
        ],
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _errorMessage != null
        ? Center(child: Text('Ошибка: $_errorMessage'))
        : Column(
            children: [
              // Поле поиска
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск пациентов...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              Expanded(
                child: ResponsiveCardList(
                  type: CardListType.patients,
                  items: _filteredPatients,
                  onDetails: (item) => _openPatientDetails(item as Map<String, dynamic>),
                  onHistory: (item) => _openPatientHistory(item as Map<String, dynamic>),
                  onRefresh: _refreshPatients,
                ),
              ),
            ],
          ),
    );
  }
}
