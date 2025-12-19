import 'package:flutter/material.dart';
import 'package:not_a_writing_app/widgets/book_about_section.dart';
import 'package:not_a_writing_app/widgets/book_action_button.dart';
import 'package:not_a_writing_app/widgets/book_author_section.dart';
import 'package:not_a_writing_app/widgets/book_rating_row.dart';
import 'package:not_a_writing_app/widgets/book_suggestion_tile.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade50,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Book Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            BookActionButton(),
            SizedBox(height: 12),
            BookAuthorSection(),
            SizedBox(height: 6),
            BookRatingRow(),
            SizedBox(height: 16),
            BookAboutSection(),
            SizedBox(height: 24),
            Text(
              'You may also like',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            BookSuggestionTile(title: 'BOOK TITLE'),
            BookSuggestionTile(title: 'THE NOVEL'),
          ],
        ),
      ),
    );
  }
}
