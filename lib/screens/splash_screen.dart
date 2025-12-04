import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // TOP wave
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              'assets/wave_right.png',
              fit: BoxFit.cover,
            ),
          ),

          // BOTTOM wave
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              'assets/wave_left.png',
              fit: BoxFit.cover,
            ),
          ),

        ],
      ),
    );
  }
}
