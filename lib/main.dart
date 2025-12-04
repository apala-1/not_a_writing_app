import 'package:flutter/material.dart';
import 'package:not_a_writing_app/screens/splash_screen.dart';
import 'package:not_a_writing_app/screens/onboarding_screen.dart';
import 'package:not_a_writing_app/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not a Writing App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),

      // IMPORTANT: Use named routes
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
