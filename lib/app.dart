import 'package:flutter/material.dart';
import 'package:not_a_writing_app/screens/dashboard_screen.dart';
import 'package:not_a_writing_app/screens/login_screen.dart';
import 'package:not_a_writing_app/screens/onboarding_screen.dart';
import 'package:not_a_writing_app/screens/signup_screen.dart';
import 'package:not_a_writing_app/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not A Writing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
