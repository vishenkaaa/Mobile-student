import 'package:flutter/material.dart';
import 'package:student_app/screens/profile_frag.dart';
import 'package:student_app/screens/schedule_frag.dart';
import 'package:student_app/screens/teachers_frag.dart';
import 'package:student_app/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ScheduleScreen(),
    TeacherScreen(),
    Center(child: Text("Оцінки"),),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.lightBlue,
        selectedItemColor: AppColors.carribbeanCurrent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_timeline_outlined),
            label: 'Розклад',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Вчителі',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Оцінки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}
