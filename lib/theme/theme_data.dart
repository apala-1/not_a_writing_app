import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    fontFamily: 'InriaSans Bold',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(255, 52, 30, 30),
        fontSize: 20,
        fontFamily: 'InriaSans Bold',
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    ),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationThemeData(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade200,
    ),
  );
}