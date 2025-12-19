import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
                top: 40,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/pencil.png',
                          height: 100,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "SIGN UP",
                          style: TextStyle(
                            color: Color(0xFFFF7F00),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 35),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: _inputStyle(
                                  icon: Icons.person,
                                  label: "full name",
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                decoration: _inputStyle(
                                  icon: Icons.email_outlined,
                                  label: "email",
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                obscureText: _obscurePassword,
                                decoration: _inputStyle(
                                  icon: Icons.lock_outline,
                                  label: "password",
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                obscureText: _obscureConfirm,
                                decoration: _inputStyle(
                                  icon: Icons.lock_outline,
                                  label: "confirm password",
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirm =
                                            !_obscureConfirm;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    activeColor:
                                        const Color(0xFFFF7F00),
                                    onChanged: (v) {
                                      setState(() {
                                        rememberMe = v!;
                                      });
                                    },
                                  ),
                                  const Text("Remember Me"),
                                ],
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFFF7F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                child: const Text(
                                  "Already have an account? Log In",
                                  style: TextStyle(
                                    color: Color(0xFFFF7F00),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    height: 28,
                                  ),
                                  const SizedBox(width: 20),
                                  Image.asset(
                                    'assets/images/facebook.png',
                                    height: 28,
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  InputDecoration _inputStyle({
    required IconData icon,
    required String label,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      suffixIcon: suffix,
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      enabledBorder: const UnderlineInputBorder(
        borderSide:
            BorderSide(color: Color(0xFFFF7F00), width: 1.3),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide:
            BorderSide(color: Color(0xFFFF7F00), width: 1.8),
      ),
    );
  }
}
