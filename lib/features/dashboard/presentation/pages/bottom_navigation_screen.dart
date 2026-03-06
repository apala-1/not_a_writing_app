import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_browser_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/dashboard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/profile_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/search_users_page.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/view_messages_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/appbar_title.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  bool _isNear = false;

  final List<Widget> lstBottomScreen = [
    const DashboardScreen(),
    const BookBrowserScreen(),
    const SearchUsersPage(),
    const ViewMessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Activate proximity lock if supported
    ProximityScreenLock.isProximityLockSupported().then((supported) {
      if (supported) {
        ProximityScreenLock.setActive(true);

        ProximityScreenLock.proximityStates.listen((objectDetected) {
          // objectDetected is true when sensor is covered
          setState(() {
            _isNear = objectDetected;
          });
          print('Proximity detected: $_isNear');
        });
      } else {
        print('Proximity lock not supported on this device');
      }
    });
  }

  @override
  void dispose() {
    ProximityScreenLock.setActive(false); // deactivate when leaving
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          lstBottomScreen[_selectedIndex],
          if (_isNear)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_outlined), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: "Profile")
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFEE7C2B),
        unselectedItemColor: Color(0xFF64748B),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}