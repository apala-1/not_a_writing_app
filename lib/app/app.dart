import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/login_screen.dart';
import 'package:not_a_writing_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_navigation_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/dashboard_screen.dart';
import 'package:not_a_writing_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:not_a_writing_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:not_a_writing_app/theme/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not A Writing App',
      theme: getApplicationTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardScreen(),
        "/bottom_navigation": (context) => const BottomNavigationScreen(),
      },
    );
  }
}
