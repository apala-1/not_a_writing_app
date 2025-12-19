import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  const AppbarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 12,),
        Container(
          height: 60,
          child: Image.asset(
            'assets/images/pencil.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 12,),
        Text(
          'Not A Writing App',
          
        ),
      ],
    );
  }
}