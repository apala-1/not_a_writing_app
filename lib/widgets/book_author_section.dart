import 'package:flutter/material.dart';

class BookAuthorSection extends StatelessWidget {
  const BookAuthorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'John Doe • Recreational Writer',
      style: TextStyle(fontSize: 14),
    );
  }
}
