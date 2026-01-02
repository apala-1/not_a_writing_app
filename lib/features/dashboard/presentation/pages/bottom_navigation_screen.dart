import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_browser_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_detail_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/dashboard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/profile_screen.dart';
import 'package:not_a_writing_app/widgets/appbar_title.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
    int _selectedIndex = 0;

  List <Widget> lstBottomScreen = [
    const DashboardScreen(),
    const BookBrowserScreen(),
    const BookDetailScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: "Write"),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: "Profile")
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFEE7C2B),
        unselectedItemColor: Color(0xFF64748B),
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex=index;
          });
        },
      ),
    );
  }
}