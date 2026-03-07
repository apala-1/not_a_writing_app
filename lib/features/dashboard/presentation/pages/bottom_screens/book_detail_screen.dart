import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chapter_reader_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';

class BookDetailScreen extends ConsumerWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookByIdProvider(bookId));

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text("Book Details", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -50, right: -50, child: _buildBlob(250, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: 100, left: -50, child: _buildBlob(300, rosePrimary.withOpacity(0.08))),

          asyncBook.when(
            loading: () => const Center(child: CircularProgressIndicator(color: orangePrimary)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (book) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Header
                    _Header(book: book),
                    const SizedBox(height: 32),

                    // 2. Metadata Chips (Styled like your React theme)
                    _buildSectionHeader("Overview"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Chip(label: 'Status: ${book.status}', icon: LucideIcons.info),
                        _Chip(label: 'Visibility: ${book.visibility}', icon: book.visibility == 'public' ? LucideIcons.globe : LucideIcons.lock),
                        _Chip(label: 'Chapters: ${book.chapters.length}', icon: LucideIcons.layers),
                        if (book.shareToken != null && book.shareToken!.isNotEmpty)
                          _Chip(label: 'Shared', icon: LucideIcons.share2),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 3. Description Glass Card
                    _buildSectionHeader("About this Story"),
                    const SizedBox(height: 12),
                    _buildGlassCard(
                      child: Text(
                        book.description,
                        style: TextStyle(height: 1.6, color: Colors.grey[800], fontSize: 15),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 4. Chapter List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader("Manuscript"),
                        Text(
                          "${book.chapters.length} Chapters",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: orangePrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5. Chapter Cards
                    ...List.generate(book.chapters.length, (i) {
                      final c = book.chapters[i];
                      return _buildChapterCard(context, book, c, i);
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: Colors.black54),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildChapterCard(BuildContext context, BookEntity book, dynamic chapter, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: orangePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text("${index + 1}", style: const TextStyle(color: orangePrimary, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
        title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("${chapter.content.length} content blocks", style: TextStyle(color: Colors.grey[500])),
        trailing: const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterReaderScreen(
                bookTitle: book.title,
                chapterIndex: index,
                chapter: chapter,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
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
        // Premium Book Cover Shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(4, 10))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              book.coverPhotoUrl,
              width: 120,
              height: 165,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120, height: 165,
                color: const Color(0xFFF97316).withOpacity(0.1),
                child: const Icon(LucideIcons.bookOpen, color: Color(0xFFF97316)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                book.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(radius: 10, backgroundColor: const Color(0xFFF97316).withOpacity(0.1), child: const Icon(LucideIcons.user, size: 10, color: Color(0xFFF97316))),
                  const SizedBox(width: 8),
                  Text(authorName, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              // Horizontal Stat Bar
              Row(
                children: [
                  _statItem(LucideIcons.fileText, book.noOfPages.toString(), "Pages"),
                  const SizedBox(width: 16),
                  _statItem(LucideIcons.layers, book.noOfChapters.toString(), "Chapters"),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFF97316)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFF43F5E)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}