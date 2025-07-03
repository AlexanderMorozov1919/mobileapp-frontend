import 'package:flutter/material.dart';

class PatientHistoryScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PatientHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final List<Map<String, dynamic>> _visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  void _loadVisits() {
    // Фиктивные данные посещений
    _visits.addAll([
      {
        'date': '12.05.2023',
        'specialist': 'Терапевт Иванова А.П.',
        'diagnosis': 'ОРВИ, острая форма',
        'recommendations': 'Постельный режим, обильное питье, прием жаропонижающих',
      },
      {
        'date': '28.07.2023',
        'specialist': 'Хирург Петров С.Д.',
        'diagnosis': 'Консультация после операции',
        'recommendations': 'Обработка шва, ограничение физических нагрузок',
      },
      {
        'date': '15.09.2023',
        'specialist': 'Кардиолог Сидорова Е.К.',
        'diagnosis': 'Контрольный осмотр',
        'recommendations': 'Продолжить прием препаратов, контроль АД',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История посещений: ${widget.patientName}'),
        backgroundColor: const Color(0xFF8B8B8B),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          return _buildVisitCard(_visits[index]);
        },
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата и специалист
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  visit['date'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  visit['specialist'],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Диагноз
            const Text(
              'Диагноз:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(visit['diagnosis']),
            const SizedBox(height: 10),
            
            // Рекомендации
            const Text(
              'Рекомендации:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(visit['recommendations']),
          ],
        ),
      ),
    );
  }
}