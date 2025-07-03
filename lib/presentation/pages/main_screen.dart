import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'patient_list_screen.dart';
import 'calls_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ScheduleScreen(),
    PatientListScreen(),
    CallsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Расписание'
              : _currentIndex == 1
                  ? 'Список пациентов'
                  : 'Вызовы',
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B8B8B), // Серый
        foregroundColor: Colors.white,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                activeIcon: Icon(Icons.calendar_today, size: 28),
                label: 'Расписание',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people, size: 28),
                label: 'Пациенты',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital_outlined),
                activeIcon: Icon(Icons.local_hospital, size: 28),
                label: 'Вызовы',
              ),
            ],
            selectedItemColor: const Color(0xFFD2B48C), // Бежевый
            unselectedItemColor: Colors.white70,
            backgroundColor: const Color(0xFF8B8B8B), // Серый
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}