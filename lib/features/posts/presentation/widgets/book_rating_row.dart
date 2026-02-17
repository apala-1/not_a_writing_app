import 'package:flutter/material.dart';

class BookRatingRow extends StatelessWidget {
  const BookRatingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
      ],
    );
  }
}
