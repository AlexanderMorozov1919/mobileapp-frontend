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
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = date == _selectedDate;
              final dayName = _getDayName(date.weekday);
              
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
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
                      Text(
                        '${date.day}.${date.month}',
                        style: TextStyle(
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
            itemCount: 8, // С 8:00 до 16:00
            itemBuilder: (context, index) {
              final hour = 8 + index;
              return _buildTimeSlot(hour);
            },
          ),
        ),
      ],
    );
  }

  // Виджет временного интервала
  Widget _buildTimeSlot(int hour) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Временной интервал
          SizedBox(
            width: 80,
            child: Text(
              '$hour:00 - ${hour + 1}:00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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