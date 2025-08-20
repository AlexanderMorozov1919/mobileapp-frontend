// pages/patient_history_screen.dart
import 'package:demo_app/presentation/pages/consultation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/services/api_client.dart';

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
  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  
    try {
      final patientId = widget.patientId.toString();
      final response = await apiClient.getPatientReceptionsHistory(patientId);
      
      // Извлекаем список посещений из data.hits
      final List<dynamic> hits = response['data']['hits'] ?? [];
      
      final visits = hits.map((reception) {
      final doctor = reception['doctor'] as Map<String, dynamic>?;
        
        return {
          'reception_id': reception['id'] as int?,        // id приёма
          'doctor': doctor, 
          'date': _formatDate(reception['date']?.toString() ?? ''),
          // Специализация теперь хранится как строка
          'diagnosis': reception['diagnosis']?.toString() ?? 'Диагноз не указан',
          'recommendations': reception['recommendations']?.toString() ?? 'Рекомендации не указаны',
        };
      }).toList();
  
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      // Удаляем временную зону для корректного парсинга
      final cleanedDate = dateString.replaceFirst(RegExp(r'\+.*'), '');
      final dateTime = DateTime.parse(cleanedDate);

      // Форматируем дату и время
      final date = '${dateTime.day.toString().padLeft(2, '0')}.'
                   '${dateTime.month.toString().padLeft(2, '0')}.'
                   '${dateTime.year}';

      final time = '${dateTime.hour.toString().padLeft(2, '0')}:'
                   '${dateTime.minute.toString().padLeft(2, '0')}';

      return '$date в $time';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История посещений: ${widget.patientName}'),
        backgroundColor: const Color(0xFF5F9EA0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _visits.isEmpty
                  ? const Center(child: Text('История посещений пуста'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _visits.length,
                      itemBuilder: (context, index) {
                        final visit = _visits[index];
                        return InkWell(
                          onTap: () {;
                            final doctor = visit['doctor'];
                            if (doctor is Map<String, dynamic>) {
                              final doctorId = doctor['doctor_id'];
                              print('Doctor ID: $doctorId');
                            } else {
                              print('doctor is not a Map: $doctor');
                            }
                            final doctorId = doctor != null ? doctor['doctor_id'] as int? : null;
                            final int? receptionId = visit['reception_id'];
                            print('Recep ID: $receptionId');
                            if (doctorId == null || receptionId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ошибка: отсутствуют необходимые данные для загрузки заключения')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConsultationScreen(
                                  patientName: widget.patientName,
                                  appointmentType: 'reception', // или динамически, если есть
                                  recordId: receptionId,
                                  doctorId: doctorId,
                                  // recordId: visit['id'] as int,
                                  // doctorId: visit['doctor_id'] as int? ?? 0,
                                  isReadOnly: true, // Открываем только для просмотра
                                ),
                              ),
                            );
                          },
                          child: _buildVisitCard(visit),
                        );
                      },
                    ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    final doctor = visit['doctor'] ?? {};
    final String doctorName = doctor['full_name'] ?? 'Неизвестно';
    final String specialization = doctor['specialization'] ?? 'Не указано';
    final String diagnosis = visit['diagnosis'] ?? '';
    final String recommendations = visit['recommendations'] ?? '';
    final String date = visit['date'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата
            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Информация о враче
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        specialization,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Диагноз
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Диагноз:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text(diagnosis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Рекомендации
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.receipt, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Рекомендации:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(recommendations),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}