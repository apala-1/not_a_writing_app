import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/presentation/widgets/normal_button.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Row(
            children: [
              GestureDetector(onTap: () => {
                Navigator.pushReplacementNamed(context, '/login')
              }, child: Icon(Icons.arrow_back)),
            ],
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset('assets/images/pencil.png', height: 90),
                  SizedBox(height: 40,),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: 'Enter email',
                      hintText: 'abc@gmail.com'
                    ),
                  ),
                  SizedBox(height: 25,),
                  NormalButton(text: 'Send Reset Link', onPressed: () => {},)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}