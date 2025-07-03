import 'package:flutter/material.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    // Загрузка фиктивных данных пациентов
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    // Фиктивные данные пациентов
    _patients = [
      {
        'id': 1,
        'fullName': 'Иванов Иван Иванович',
        'room': 'Палата 101',
        'diagnosis': 'Гипертоническая болезнь II ст.',
        'photoUrl': null,
      },
      {
        'id': 2,
        'fullName': 'Петрова Мария Сергеевна',
        'room': 'Палата 205',
        'diagnosis': 'Сахарный диабет 2 типа',
        'photoUrl': null,
      },
      {
        'id': 3,
        'fullName': 'Сидоров Алексей Петрович',
        'room': 'Палата 312',
        'diagnosis': 'Острый бронхит',
        'photoUrl': null,
      },
      {
        'id': 4,
        'fullName': 'Кузнецова Елена Викторовна',
        'room': 'Палата 104',
        'diagnosis': 'Язвенная болезнь желудка',
        'photoUrl': null,
      },
      {
        'id': 5,
        'fullName': 'Николаев Дмитрий Олегович',
        'room': 'Палата 209',
        'diagnosis': 'Остеохондроз позвоночника',
        'photoUrl': null,
      },
      {
        'id': 6,
        'fullName': 'Фёдорова Анна Михайловна',
        'room': 'Палата 303',
        'diagnosis': 'Пневмония',
        'photoUrl': null,
      },
    ];
    _filteredPatients = _patients;
  }

  void addNewPatient(Map<String, dynamic> patientData) {
    setState(() {
      _patients.add({
        'id': _patients.length + 1,
        'fullName': patientData['fullName'] ?? 'Новый пациент',
        'room': 'Палата не назначена',
        'diagnosis': 'Диагноз не установлен',
      });
      _filteredPatients = _patients;
    });
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredPatients = _patients);
    } else {
      setState(() {
        _filteredPatients = _patients.where((patient) {
          return patient['fullName'].toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель поиска и фильтров
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Поле поиска
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по ФИО пациента',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Более круглые углы
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Кнопка фильтра
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, size: 25, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Фильтрация будет реализована позже')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Список пациентов
        Expanded(
          child: ListView.builder(
            itemCount: _filteredPatients.length,
            itemBuilder: (context, index) {
              final patient = _filteredPatients[index];
              return _buildPatientCard(patient);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ФИО пациента
            Text(
              patient['fullName'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Информация о палате и диагнозе
            Row(
              children: [
                // Номер палаты
                Row(
                  children: [
                    Icon(Icons.bed, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 5),
                    Text(
                      patient['room'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                
                // Диагноз
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          patient['diagnosis'],
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Кнопки действий
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопка истории болезни
                OutlinedButton.icon(
                  icon: Icon(Icons.history, size: 18, color: Theme.of(context).primaryColor),
                  label: Text('История', style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Кнопка подробнее
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Подробнее'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2B48C), // Бежевый
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    void addNewPatient(Map<String, dynamic> patientData) {
    setState(() {
      _patients.add({
        'id': _patients.length + 1,
        'fullName': patientData['fullName'] ?? 'Новый пациент',
        'room': 'Палата не назначена',
        'diagnosis': 'Диагноз не установлен',
      });
      _filteredPatients = _patients;
    });
    }
  }
}