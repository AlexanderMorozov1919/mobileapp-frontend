import 'package:flutter/material.dart';

class DateCarousel extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final double dateItemWidth;
  final int daysRange;
  final double height;

  const DateCarousel({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.dateItemWidth = 86.0,
    this.daysRange = 15,
    this.height = 90,
  });

  @override
  _DateCarouselState createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  late DateTime _selectedDate;
  late List<DateTime> _dates;
  late ScrollController _scrollController;
  late DateTime _centerDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _centerDate = _selectedDate;
    _dates = _generateDates();
    _scrollController = ScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedDate();
    });
  }

  @override
  void didUpdateWidget(DateCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate;
        if (_dates.every((date) => !_isSameDate(date, _selectedDate))) {
          _centerDate = _selectedDate;
          _dates = _generateDates();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _centerSelectedDate();
          });
        } else {
          _centerSelectedDate();
        }
      });
    }
  }

  List<DateTime> _generateDates() {
    final halfRange = widget.daysRange ~/ 2;
    return List.generate(widget.daysRange, (index) {
      return _centerDate.subtract(Duration(days: halfRange - index));
    });
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _centerSelectedDate() {
    final selectedIndex = _dates.indexWhere((date) => _isSameDate(date, _selectedDate));
    if (selectedIndex != -1) {
      final viewportWidth = MediaQuery.of(context).size.width;
      final centerPosition = selectedIndex * widget.dateItemWidth - 
                           (viewportWidth / 2) + 
                           (widget.dateItemWidth / 2);
      
      _scrollController.animateTo(
        centerPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _isSameDate(date, _selectedDate);
          final dayName = _getDayName(date.weekday);
          final isToday = _isSameDate(date, DateTime.now());
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF4682B4)
                  : isToday
                    ? const Color(0xFFB0C4DE).withOpacity(0.3)
                    : const Color(0xFFB0C4DE),
                shape: BoxShape.circle,
                border: isToday
                  ? Border.all(color: const Color(0xFFD2B48C), width: 2)
                  : null,
                boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
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
    );
  }
}