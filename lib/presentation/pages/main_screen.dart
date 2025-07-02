import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'patient_list_screen.dart'; // Переименованный файл
import 'visit_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ScheduleScreen(),
    PatientListScreen(), // Переименованный виджет
    VisitScreen(),
  ];

  final List<String> _pageTitles = [
    'Расписание',
    'Список пациентов', // Новый заголовок
    'Выезд',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), // Новая иконка
            label: 'Пациенты', // Новое название
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