import 'package:flutter/material.dart';
import 'add_patient_screen.dart';
import 'consultation_screen.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _filteredCalls = [];
  Set<int> _completedCalls = Set();

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  void _loadCalls() {
    // Фиктивные данные вызовов
    _calls = [
      {
        'id': 1,
        'patientName': 'Смирнов Александр Петрович',
        'address': 'ул. Ленина, д. 15, кв. 42',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '10:30',
        'doctor': 'Иванова М.П.',
      },
      {
        'id': 2,
        'patientName': 'Козлова Ольга Ивановна',
        'address': 'пр. Победы, д. 87, кв. 12',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '11:15',
        'doctor': 'Петров А.В.',
      },
      {
        'id': 3,
        'patientName': 'Васильев Дмитрий Сергеевич',
        'address': 'ул. Садовая, д. 5, кв. 34',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '12:40',
        'doctor': 'Сидорова Е.К.',
      },
      {
        'id': 4,
        'patientName': 'Никитина Елена Владимировна',
        'address': 'пр. Строителей, д. 23, кв. 7',
        'status': 'НЕОТЛОЖНЫЙ',
        'time': '13:20',
        'doctor': 'Фёдоров И.Д.',
      },
      {
        'id': 5,
        'patientName': 'Горбачёв Михаил Юрьевич',
        'address': 'ул. Центральная, д. 1, кв. 89',
        'status': 'ЭКСТРЕННЫЙ',
        'time': '14:50',
        'doctor': 'Иванова М.П.',
      },
    ];
    
    // Сортируем: сначала экстренные, затем по времени
    _filteredCalls = List.from(_calls)
      ..sort((a, b) {
        if (a['status'] == 'ЭКСТРЕННЫЙ' && b['status'] != 'ЭКСТРЕННЫЙ') {
          return -1;
        } else if (a['status'] != 'ЭКСТРЕННЫЙ' && b['status'] == 'ЭКСТРЕННЫЙ') {
          return 1;
        }
        return a['time'].compareTo(b['time']);
      });
  }

  void _refreshCalls() {
    setState(() {
      _loadCalls();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Список вызовов обновлён')),
      );
    });
  }

  void _addNewPatient(BuildContext context) {
    // Открываем экран добавления пациента и ждем результат
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPatientScreen(),
      ),
    ).then((newPatient) {
      if (newPatient != null) {
        // Переходим на экран пациентов и добавляем нового пациента
        // В реальном приложении здесь будет вызов метода добавления
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новый пациент добавлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _startCallConsultation(Map<String, dynamic> call) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ConsultationScreen(
        patientName: call['patientName'],
        appointmentType: 'call',
        recordId: call['id'],
      ),
    ),
  ).then((result) {
    if (result != null) {
      setState(() {
        _completedCalls.add(call['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заключение по вызову ${call['patientName']} сохранено'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Вызовы',
            style: TextStyle(color: Color(0xFF8B8B8B)),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshCalls,
              tooltip: 'Обновить список',
              color: Color(0xFF8B8B8B),
            ),
          ],
        ),
      body: ListView.builder(
        itemCount: _filteredCalls.length,
        itemBuilder: (context, index) {
          final call = _filteredCalls[index];
          return _buildCallCard(call);
        },
      ),
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call) {
  
  return CustomCard(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Статус вызова
                StatusChip(
                  text: call['status'],
                  isEmergency: call['status'] == 'ЭКСТРЕННЫЙ',
                ),
                
                // Время вызова
                Text(
                  call['time'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // ФИО пациента
            Text(
              call['patientName'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Адрес
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call['address'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Лечащий врач
            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Врач: ${call['doctor']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            
            // Кнопки действий
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Кнопка принятия вызова
                OutlinedButton.icon(
                  icon: Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).primaryColor),
                  label: Text('Принять', style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () => _startCallConsultation(call),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Кнопка деталей
                ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Детали'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2B48C), // Бежевый
                  ),
                ),
              ],
            ),
          ],
       ),
    );
  }
}