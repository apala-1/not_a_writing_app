import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>{

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if(!context.mounted) return;
        final userSessionService = ref.read(userSessionServiceProvider);
        final isLoggedIn = userSessionService.isLoggedIn();

        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, '/bottom_navigation');
        } else {
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
                child: Image.asset("assets/images/top_right.png"),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset("assets/images/bottom_left.png"),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/pencil.png", height: 100),
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