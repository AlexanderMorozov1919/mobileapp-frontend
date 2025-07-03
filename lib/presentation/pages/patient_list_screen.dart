import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'patient_history_screen.dart';

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
        'gender': 'Мужской',
        'birthDate': '15.03.1965',
        'snils': '123-456-789 01',
        'oms': '1234567890123456',
        'passport': '45 06 123456',
        'address': 'г. Москва, ул. Ленина, д. 15, кв. 42',
        'phone': '+7 (999) 123-45-67',
        'email': 'ivanov@example.com',
        'contraindications': 'Аллергия на пенициллин',
    },
    {
        'id': 2,
        'fullName': 'Петрова Анна Сергеевна',
        'room': 'Палата 205',
        'diagnosis': 'Сахарный диабет 2 типа',
        'gender': 'Женский',
        'birthDate': '22.07.1978',
        'snils': '234-567-890 12',
        'oms': '2345678901234567',
        'passport': '40 07 234567',
        'address': 'г. Санкт-Петербург, ул. Пушкина, д. 10, кв. 15',
        'phone': '+7 (911) 234-56-78',
        'email': 'petrova@example.com',
        'contraindications': 'Нет',
    },
    {
        'id': 3,
        'fullName': 'Сидоров Михаил Петрович',
        'room': 'Палата 102',
        'diagnosis': 'ХОБЛ, среднетяжелое течение',
        'gender': 'Мужской',
        'birthDate': '05.11.1952',
        'snils': '345-678-901 23',
        'oms': '3456789012345678',
        'passport': '41 08 345678',
        'address': 'г. Новосибирск, ул. Гагарина, д. 5, кв. 33',
        'phone': '+7 (912) 345-67-89',
        'email': 'sidorov@example.com',
        'contraindications': 'Бронхиальная астма',
    },
    {
        'id': 4,
        'fullName': 'Кузнецова Елена Владимировна',
        'room': 'Палата 306',
        'diagnosis': 'Остеоартроз коленных суставов',
        'gender': 'Женский',
        'birthDate': '18.09.1960',
        'snils': '456-789-012 34',
        'oms': '4567890123456789',
        'passport': '42 09 456789',
        'address': 'г. Екатеринбург, ул. Мира, д. 20, кв. 7',
        'phone': '+7 (913) 456-78-90',
        'email': 'kuznetsova@example.com',
        'contraindications': 'Непереносимость НПВС',
    },
    {
        'id': 5,
        'fullName': 'Смирнов Алексей Дмитриевич',
        'room': 'Палата 103',
        'diagnosis': 'ИБС, стенокардия напряжения II ФК',
        'gender': 'Мужской',
        'birthDate': '30.01.1972',
        'snils': '567-890-123 45',
        'oms': '5678901234567890',
        'passport': '43 10 567890',
        'address': 'г. Казань, ул. Чехова, д. 12, кв. 24',
        'phone': '+7 (914) 567-89-01',
        'email': 'smirnov@example.com',
        'contraindications': 'Язвенная болезнь желудка',
    },
    {
        'id': 6,
        'fullName': 'Федорова Ольга Игоревна',
        'room': 'Палата 207',
        'diagnosis': 'Хронический пиелонефрит',
        'gender': 'Женский',
        'birthDate': '14.05.1985',
        'snils': '678-901-234 56',
        'oms': '6789012345678901',
        'passport': '44 11 678901',
        'address': 'г. Нижний Новгород, ул. Горького, д. 8, кв. 19',
        'phone': '+7 (915) 678-90-12',
        'email': 'fedorova@example.com',
        'contraindications': 'Хроническая почечная недостаточность',
    },
    {
        'id': 7,
        'fullName': 'Попов Денис Александрович',
        'room': 'Палата 104',
        'diagnosis': 'Язвенная болезнь 12-перстной кишки',
        'gender': 'Мужской',
        'birthDate': '27.12.1979',
        'snils': '789-012-345 67',
        'oms': '7890123456789012',
        'passport': '45 12 789012',
        'address': 'г. Самара, ул. Куйбышева, д. 25, кв. 11',
        'phone': '+7 (916) 789-01-23',
        'email': 'popov@example.com',
        'contraindications': 'Аллергия на метронидазол',
    },
    {
        'id': 8,
        'fullName': 'Волкова Татьяна Николаевна',
        'room': 'Палата 308',
        'diagnosis': 'Бронхиальная астма, атопическая',
        'gender': 'Женский',
        'birthDate': '03.08.1992',
        'snils': '890-123-456 78',
        'oms': '8901234567890123',
        'passport': '46 13 890123',
        'address': 'г. Ростов-на-Дону, ул. Садовая, д. 3, кв. 5',
        'phone': '+7 (917) 890-12-34',
        'email': 'volkova@example.com',
        'contraindications': 'Поливалентная лекарственная аллергия',
    }
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
                icon: const Icon(Icons.history, size: 18),
                label: const Text('История'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHistoryScreen(
                        patientId: patient['id'],
                        patientName: patient['fullName'],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              
              // Кнопка подробнее
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Подробнее'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailScreen(patient: patient),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}