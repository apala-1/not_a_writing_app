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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Go to login
            Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "<  Log In",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFF7F00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),


            const SizedBox(height: 30),


            const SizedBox(height: 20),

            // Logo
            Image.asset(
              'assets/pencil.png',
              height: 100,
            ),

            const SizedBox(height: 15),

            // SIGN UP TEXT
            const Text(
              "SIGN UP",
              style: TextStyle(
                color: Color(0xFFFF7F00),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            // FORM FIELDS
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    decoration: _inputStyle(
                      icon: Icons.person,
                      label: "full name",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    decoration: _inputStyle(
                      icon: Icons.email_outlined,
                      label: "email",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
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
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
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
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Checkbox Row
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Color(0xFFFF7F00),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember Me"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Already have account?
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // Social Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', height: 28),
                      const SizedBox(width: 20),
                      Image.asset('assets/facebook.png', height: 28),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Bottom curve
            Image.asset(
              'assets/wave_left.png',
              height: 120,
            ),
          ],
        ),
      ),
    );
  }

  // INPUT STYLE FUNCTION
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
        borderSide: BorderSide(color: Color(0xFFFF7F00), width: 1.3),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF7F00), width: 1.8),
      ),
    );
  }
}
