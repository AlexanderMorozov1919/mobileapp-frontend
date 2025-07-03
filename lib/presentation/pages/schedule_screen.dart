import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    // Генерация дат: 7 дней назад и 7 дней вперед
    final today = DateTime.now();
    _dates = List.generate(15, (index) => today.add(Duration(days: index - 7)));
  }

 @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Карусель с датами (горизонтальный список)
        SizedBox(
          height: 90, // Немного увеличим высоту
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = date == _selectedDate;
              final dayName = _getDayName(date.weekday);
              final isToday = date.day == DateTime.now().day && 
                              date.month == DateTime.now().month &&
                              date.year == DateTime.now().year;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : isToday
                        ? const Color(0xFFD2B48C).withOpacity(0.3) // Бежевый для сегодня
                        : const Color(0xFFE0E0E0), // Светло-серый
                    shape: BoxShape.circle, // Круглая форма вместо прямоугольной
                    border: isToday
                      ? Border.all(color: const Color(0xFFD2B48C), width: 2)
                      : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Заголовок с выбранной датой
        Text(
          'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 20),
        
        // Список временных слотов
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              final hour = 8 + index;
              return _buildTimeSlot(hour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlot(int hour) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Временной интервал - теперь вертикально
            Container(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$hour:00',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hour + 1}:00',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Вертикальный разделитель
            const VerticalDivider(width: 20, thickness: 1),
            
            // Детали приема
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прием пациентов',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Кабинет ${201 + hour % 3}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Иванов И.И., Петров П.П., Сидоров С.С.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Преобразование номера дня недели в название
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Пн';
      case 2: return 'Вт';
      case 3: return 'Ср';
      case 4: return 'Чт';
      case 5: return 'Пт';
      case 6: return 'Сб';
      case 7: return 'Вс';
      default: return '';
    }
  }
}