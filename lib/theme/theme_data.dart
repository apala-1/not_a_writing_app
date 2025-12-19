import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    fontFamily: 'InriaSans Bold',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: Colors.white,
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