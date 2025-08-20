import 'package:flutter/material.dart';
import '../widgets/status_chip.dart';

class CallCard extends StatelessWidget {
  final Map<String, dynamic> call;
  final VoidCallback onTap;

  const CallCard({
    super.key,
    required this.call,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = call['emergency'] == true;
    final bool isCompleted = call['isCompleted'] ?? false;

    final String mainStatus = isEmergency ? 'Экстренный' : 'Неотложный';
    final String executionStatus = isCompleted ? 'Завершён' : 'Выполняется';

    final patients = call['patients'] as List<dynamic>;
    final completedCount = patients.where((p) => p['hasConclusion'] == true).length;
    final totalPatients = patients.length;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основной статус и время
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(
                        text: mainStatus,
                        isEmergency: isEmergency,
                      ),
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
                  
                  Text(
                    '${call['address']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.phone, size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Телефон: ${call['phone']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Пациенты: $completedCount/$totalPatients завершено',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28), // Отступ под статус выполнения
                ],
              ),

              // Статус выполнения в правом нижнем углу
              Positioned(
                right: 0,
                bottom: 0,
                child: Text(
                  executionStatus,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Color(0xFF1E90FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
