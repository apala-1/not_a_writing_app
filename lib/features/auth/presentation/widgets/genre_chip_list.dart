import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Chip(
              label: Text(
                genres[index],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppColors.lightOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1.5,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }
}
