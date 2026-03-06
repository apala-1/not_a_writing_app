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

  // Modern Orange Rose Palette
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color backgroundLight = Color(0xFFFFF5F5);

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
          if (mounted) {
            setState(() {
              _isNear = objectDetected;
            });
          }
          debugPrint('Proximity detected: $_isNear');
        });
      } else {
        debugPrint('Proximity lock not supported on this device');
      }
    });
  }

  @override
  void dispose() {
    ProximityScreenLock.setActive(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: lstBottomScreen[_selectedIndex],
          ),
          
          // Proximity Blur Overlay
          if (_isNear)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off, color: Colors.white, size: 60),
                        SizedBox(height: 10),
                        Text(
                          "Privacy Mode Active",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: [
                _buildNavItem(Icons.home_rounded, Icons.home_outlined, "Home"),
                _buildNavItem(Icons.menu_book_rounded, Icons.menu_book_outlined, "Library"),
                _buildNavItem(Icons.search_rounded, Icons.search_outlined, "Search"),
                _buildNavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, "Inbox"),
                _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, "Profile"),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: primaryOrange,
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(inactiveIcon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryOrange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(activeIcon, color: primaryOrange),
      ),
      label: label,
    );
  }
}
