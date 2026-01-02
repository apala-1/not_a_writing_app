import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_about_section.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_action_button.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_author_section.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_rating_row.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_suggestion_tile.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/book_cover_two.png', 
                height: 480,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // Read Button
            BookActionButton(),

            const SizedBox(height: 12),
            const BookAuthorSection(),
            const SizedBox(height: 6),
            const BookRatingRow(),
            const SizedBox(height: 16),
            const BookAboutSection(),
            const SizedBox(height: 24),

            const Text(
              'You may also like',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const BookSuggestionTile(title: 'BOOK TITLE'),
            const BookSuggestionTile(title: 'THE NOVEL'),
          ],
        ),
      ),
    );
  }
}
