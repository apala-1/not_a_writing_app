import 'package:flutter/material.dart';
import 'package:not_a_writing_app/theme/colors.dart';
import 'package:not_a_writing_app/widgets/book_list_tile.dart';
import 'package:not_a_writing_app/widgets/book_search_bar.dart';
import 'package:not_a_writing_app/widgets/genre_chip_list.dart';
import 'package:not_a_writing_app/widgets/section_header.dart';

class BookBrowserScreen extends StatelessWidget {
  const BookBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1.5,
        shadowColor: Colors.black12,
        title: const Text(
          'Browse Books',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            // 🔍 Search bar
            BookSearchBar(),

            SizedBox(height: 16),

            // 📚 Genre chips
            GenreChipList(),

            SizedBox(height: 24),

            // 📖 Book List
            SectionHeader(title: 'Book List'),
            BookListTile(
              title: 'OTHER LONDON',
              author: 'M.V. STOTT',
              label: 'Book One',
            ),
            BookListTile(
              title: 'WALK INTO THE SHADOW',
              author: 'Unknown',
              label: 'Book Two',
            ),

            SizedBox(height: 24),

            // 🌟 Most Popular
            SectionHeader(title: 'Most Popular'),
            BookListTile(
              title: 'BOOK TITLE',
              author: 'AUTHOR NAME',
              label: 'Book One',
            ),
            BookListTile(
              title: 'THE NOVEL',
              author: 'AUTHOR NAME',
              label: 'Book Two',
            ),
          ],
        ),
      ),
    );
  }
}
