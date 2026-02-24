import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_list_tile.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/book_search_bar.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/genre_chip_list.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/section_header.dart';
import 'package:not_a_writing_app/theme/colors.dart';

class BookBrowserScreen extends StatefulWidget {
  const BookBrowserScreen({super.key});

  @override
  State<BookBrowserScreen> createState() => _BookBrowserScreenState();
}

class _BookBrowserScreenState extends State<BookBrowserScreen> {
  void _showCreateOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Create from Posts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/createFromPosts");
              },
            ),
            ListTile(
              title: const Text("Create Blank"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/createBlank");
              },
            ),
          ],
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            // Search bar
            BookSearchBar(),

            SizedBox(height: 16),

            // Genre chips
            GenreChipList(),

            SizedBox(height: 24),

            // Book List
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

            // Most Popular
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
