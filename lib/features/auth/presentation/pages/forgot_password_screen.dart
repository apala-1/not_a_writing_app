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
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: AppColors.background,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Forgot Password?", style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w500
                    ),),
                  ),
                  SizedBox(height: 3,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Change your password by getting a link in your email.', style: TextStyle(
                      color: const Color.fromARGB(255, 122, 59, 0)
                    ),),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _emailController,
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