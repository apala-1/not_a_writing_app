import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/wave_right.png',
                   width: 180,
                ),
              ),
              Image.asset(
                'assets/pencil.png',
                height: 90.0,
              ),
              Text('LOGIN', 
                    style: TextStyle(
                              color: Color(0xFFFF7F00),
                              fontWeight: FontWeight.bold,
                              fontSize: 22
                            ),
                  ),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0XFFFF7F00),
                      width: 1.5
                    )
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFFF7F00),
                      width: 1.5
                    )
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      // write the code for when error is there
                    )
                  ),
                  icon: Icon(Icons.mail),
                  labelText: 'email',
                  hintText: 'abc@gmail.com'
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0XFFFF7F00),
                      width: 1.5
                    )
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFFF7F00),
                      width: 1.5
                    )
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                      // write the code for when error is there
                    )
                  ),
                  icon: Icon(Icons.lock),
                  labelText: 'password',
                  hintText: '********'
                ),
              )
            ],
          ),
      ),
    );
  }
}