import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to onboarding after 2 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // TOP wave
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset('assets/wave_right.png', fit: BoxFit.cover),
          ),

          // BOTTOM wave
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Image.asset('assets/wave_left.png', fit: BoxFit.cover),
          ),

          // Center logo + title
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/pencil.png', width: 120),
                const SizedBox(height: 14),
                const Text(
                  "Not A Writing App",
                  style: TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
