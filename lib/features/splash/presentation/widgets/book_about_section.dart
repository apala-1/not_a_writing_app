import 'package:flutter/material.dart';

class BookAboutSection extends StatelessWidget {
  const BookAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'About Work:\nLorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      style: TextStyle(height: 1.4),
    );
  }
}
