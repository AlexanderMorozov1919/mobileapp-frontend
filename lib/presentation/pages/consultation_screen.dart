import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientName;
  final String appointmentType; // 'appointment' или 'call'
  final int recordId; // id приёма или вызова

  const ConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentType,
    required this.recordId,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _diagnosisController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final List<MedicalService> _services = [];
  final List<MedicalService> _selectedServices = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Загрузка списка услуг (в реальном приложении из API/БД)
    _loadServices();
  }

  void _loadServices() {
    // Фиктивные данные услуг
    _services.addAll([
      MedicalService(id: 1, name: 'Первичный осмотр терапевта', price: 1500.0),
      MedicalService(id: 2, name: 'ЭКГ с расшифровкой', price: 800.0),
      MedicalService(id: 3, name: 'Общий анализ крови', price: 1200.0),
      MedicalService(id: 4, name: 'УЗИ брюшной полости', price: 2500.0),
      MedicalService(id: 5, name: 'Внутривенная инъекция', price: 300.0),
      MedicalService(id: 6, name: 'Консультация специалиста', price: 1800.0),
      MedicalService(id: 7, name: 'Перевязка', price: 500.0),
      MedicalService(id: 8, name: 'Вызов на дом', price: 2000.0),
    ]);
  }

  void _updateSelectedService(MedicalService service, bool selected) {
    setState(() {
      if (selected) {
        _selectedServices.add(service);
      } else {
        _selectedServices.remove(service);
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    _totalPrice = _selectedServices.fold(
      0.0,
      (sum, service) => sum + service.price,
    );
  }

  void _submitConsultation() {
    // В реальном приложении здесь будет сохранение в БД
    // Возвращаем результат с данными заключения
    Navigator.pop(context, {
      'recordId': widget.recordId,
      'diagnosis': _diagnosisController.text,
      'recommendations': _recommendationsController.text,
      'services': _selectedServices,
      'totalPrice': _totalPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заключение для ${widget.patientName}'),
        backgroundColor: const Color(0xFF8B8B8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitConsultation,
            tooltip: 'Сохранить заключение',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Заголовок
            Text(
              widget.appointmentType == 'appointment'
                  ? 'Заключение по приёму'
                  : 'Заключение по вызову',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Диагноз
            const Text(
              'Диагноз:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Укажите диагноз пациента',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            
            // Рекомендации
            const Text(
              'Рекомендации:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _recommendationsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Назначения и рекомендации для пациента',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            
            // Оказанные услуги
            const Text(
              'Оказанные услуги:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._services.map((service) {
              return _buildServiceItem(service);
            }).toList(),
            const SizedBox(height: 20),
            
            // Итоговая сумма
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ИТОГО:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} руб.',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Кнопка сохранения
            ElevatedButton(
              onPressed: _submitConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B8B8B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Сохранить заключение',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(MedicalService service) {
    final isSelected = _selectedServices.contains(service);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? Colors.blue[50] : null,
      child: CheckboxListTile(
        title: Text(service.name),
        subtitle: Text('${service.price.toStringAsFixed(2)} руб.'),
        value: isSelected,
        onChanged: (value) => _updateSelectedService(service, value ?? false),
        secondary: const Icon(Icons.medical_services, color: Colors.blue),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

// Модель медицинской услуги
class MedicalService {
  final int id;
  final String name;
  final double price;

  MedicalService({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalService &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}