import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/auth/presentation/widgets/normal_button.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewmodelProvider, (previous, next) {
      if (previous?.status == AuthStatus.loading &&
          next.status != AuthStatus.loading) {
        
        if (next.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage ?? "Something went wrong")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reset link sent to your email")),
          );
        }
      }
    });
    final state = ref.watch(authViewmodelProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: AppColors.background,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset('assets/images/pencil.png', height: 90),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Change your password by getting a link in your email.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 122, 59, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: 'Enter email',
                      hintText: 'abc@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 25),
                  state.status == AuthStatus.loading
                      ? const CircularProgressIndicator()
                      : NormalButton(
                          text: 'Send Reset Link',
                          onPressed: () {
                            final email = _emailController.text.trim();

                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email cannot be empty"),
                                ),
                              );
                              return;
                            }

                            ref
                                .read(authViewmodelProvider.notifier)
                                .forgotPassword(email);
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
