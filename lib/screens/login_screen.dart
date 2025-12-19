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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
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
                          height: 90,
                        ),

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

                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: "Email",
                            hintText: "abc@gmail.com",
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFFFF7F00)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFFFF7F00)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            labelText: "Password",
                            hintText: "********",
                            enabledBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFFFF7F00)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFFFF7F00)),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor:
                                      const Color(0xFFFF7F00),
                                  onChanged: (v) {
                                    setState(() {
                                      _rememberMe = v!;
                                    });
                                  },
                                ),
                                const Text("Remember Me"),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFFFF7F00),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
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
                                    "Log In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/signup');
                          },
                          child: const Text(
                            "Don't have an account yet? Sign In",
                            style: TextStyle(
                              color: Color(0xFFFF7F00),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector( onTap: () { Navigator.pushReplacementNamed(context, '/bottom_navigation'); },
                              child: Image.asset(
                                'assets/images/google.png',
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Image.asset(
                              'assets/images/facebook.png',
                              height: 40,
                            ),
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
