import 'package:flutter/material.dart';

class GenreChipList extends StatelessWidget {
  const GenreChipList({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['Horror', 'Mystery', 'Self-Help', 'Romance'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              label: Text(genres[index]),
              backgroundColor: Colors.pink.shade100,
            ),
          );
        },
      ),
    );
  }
}
