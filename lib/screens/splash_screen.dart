import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if(context.mounted){
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset("assets/top_right.png"),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset("assets/bottom_left.png"),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/pencil.png", height: 100),
                    SizedBox(height: 8),
                    Text("NOT A WRITING APP", style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFF7F00)
                    ),)
                  ],
                ),
              )
            ],
          ),
      ),
      );
  }
}