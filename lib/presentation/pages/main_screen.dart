import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'stationary_screen.dart';
import 'visit_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Индекс текущей вкладки

  // Список экранов приложения
  final List<Widget> _pages = [
    const ScheduleScreen(), // Экран расписания
    const StationaryScreen(), // Экран стационара (заглушка)
    const VisitScreen(), // Экран выездов (заглушка)
  ];

  // Заголовки для AppBar
  final List<String> _pageTitles = [
    'Расписание',
    'Стационар',
    'Выезд',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        centerTitle: true,
      ),
      // Отображение текущего экрана
      body: _pages[_currentIndex],
      // Нижняя навигационная панель
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Стационар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Выезд',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}