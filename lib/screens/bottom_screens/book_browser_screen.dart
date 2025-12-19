import 'package:flutter/material.dart';
import 'package:not_a_writing_app/widgets/book_list_tile.dart';
import 'package:not_a_writing_app/widgets/book_search_bar.dart';
import 'package:not_a_writing_app/widgets/genre_chip_list.dart';
import 'package:not_a_writing_app/widgets/section_header.dart';

class BookBrowserScreen extends StatelessWidget {
  const BookBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        title: const Text(
          'Browse Books',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            BookSearchBar(),
            SizedBox(height: 16),
            GenreChipList(),
            SizedBox(height: 24),

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
