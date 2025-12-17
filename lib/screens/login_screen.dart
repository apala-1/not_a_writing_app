import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset(
                        'assets/images/pencil.png',
                        height: 90,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // LOGIN Title
                      const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Color(0xFFFF7F00),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Email Field
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.mail),
                          labelText: "Email",
                          hintText: "abc@gmail.com",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF7F00),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF7F00),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password field with Eye
                      TextFormField(
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          labelText: "Password",
                          hintText: "********",
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF7F00),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF7F00),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Remember me + Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                activeColor: const Color(0xFFFF7F00),
                                value: _rememberMe,
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val!;
                                  });
                                },
                              ),
                              const Text("Remember Me"),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFFFF7F00),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                
                      GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: const Text(
                              "Don't have an account yet? Sign In",
                              style: TextStyle(
                                color: Color(0xFFFF7F00),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      
                      const SizedBox(height: 30),
                      
                      // Google & Facebook Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            },
                            child: Image.asset(
                              'assets/images/google.png',
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/images/facebook.png',
                              height: 40,
                            ),
                          )],)
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
