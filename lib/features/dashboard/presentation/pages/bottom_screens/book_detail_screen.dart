import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chapter_reader_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';


class BookDetailScreen extends ConsumerWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookByIdProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: asyncBook.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (book) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Header(book: book),
              const SizedBox(height: 16),
              Text(
                book.description,
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Chip(label: 'Status: ${book.status}'),
                  _Chip(label: 'Visibility: ${book.visibility}'),
                  _Chip(label: 'Chapters: ${book.chapters.length}'),
                  if (book.shareToken != null && book.shareToken!.isNotEmpty)
                    _Chip(label: 'Token: ${book.shareToken}'),
                ],
              ),

              const SizedBox(height: 20),
              const Text('Chapters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              ...List.generate(book.chapters.length, (i) {
                final c = book.chapters[i];
                return Card(
                  child: ListTile(
                    title: Text(c.title),
                    subtitle: Text('${c.content.length} blocks'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterReaderScreen(
                            bookTitle: book.title,
                            chapterIndex: i,
                            chapter: c,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BookEntity book;
  const _Header({required this.book});

  @override
  Widget build(BuildContext context) {
    final authorName = book.author?.name ?? 'Unknown';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            book.coverPhotoUrl,
            width: 110,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 110,
              height: 150,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('By $authorName', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 10),
              Text(
                'Pages: ${book.noOfPages} • Chapters: ${book.noOfChapters}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label),
    );
  }
}