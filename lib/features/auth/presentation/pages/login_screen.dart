import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/utils/snackbar_utils.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

Future<void> _handleGoogleLogin() async {
  try {
    // Force initialize (apply your web client ID for backend)
    await GoogleSignIn.instance.initialize(
      serverClientId: "458852825785-d4r3gpp7b9v6kmldqug9b42de7cqf8a0.apps.googleusercontent.com",
    );

    // Use the new authenticate() method
    final userData = await GoogleSignIn.instance.authenticate(
      scopeHint: ['email'],
    );

    final idToken = userData.authentication.idToken;
    if (idToken == null) throw Exception('No ID token');

    if (!mounted) return;
    await ref.read(authViewmodelProvider.notifier).loginWithGoogle(idToken);
  } catch (e) {
    if (!mounted) return;
    SnackbarUtils.showError(context, 'Google login failed: $e');
  }
}

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewmodelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Login failed');
      } else if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login successful!');
        Navigator.pushReplacementNamed(context, '/bottom_navigation');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              key: const Key('login_scroll'),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/pencil.png', height: 90),
                        const SizedBox(height: 20),
                        const Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Color(0xFFFF7F00),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.mail),
                                  labelText: "Email",
                                  hintText: "abc@gmail.com",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFFF7F00)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFFF7F00)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Email is required";
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter valid email";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock),
                                  labelText: "Password",
                                  hintText: "********",
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFFF7F00)),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFFF7F00)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Password required";
                                  if (value.length < 6) return "Min 6 chars";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF7F00),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      ref.read(authViewmodelProvider.notifier).login(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          );
                                    }
                                  },
                                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handleGoogleLogin,
                              child: Image.asset('assets/images/google.png', height: 40),
                            ),
                            const SizedBox(width: 30),
                            Image.asset('assets/images/facebook.png', height: 40),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}