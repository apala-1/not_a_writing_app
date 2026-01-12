import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const NormalButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF7F00),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white),),
    );
  }
}