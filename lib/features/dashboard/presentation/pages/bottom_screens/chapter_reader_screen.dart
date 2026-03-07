import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

class ChapterReaderScreen extends StatelessWidget {
  final String bookTitle;
  final int chapterIndex;
  final BookChapterEntity chapter;

  const ChapterReaderScreen({
    super.key,
    required this.bookTitle,
    required this.chapterIndex,
    required this.chapter,
  });

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);

  String _toFullUrl(String value) {
    final v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    print(v);
    if (v.startsWith('/uploads/')) return '${ApiEndpoints.alsoServerUrl}$v';
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background Blobs for a soft, immersive feel
          Positioned(top: 100, right: -100, child: _buildBlob(300, orangePrimary.withOpacity(0.05))),
          Positioned(bottom: 200, left: -100, child: _buildBlob(350, rosePrimary.withOpacity(0.05))),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: orangePrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "CHAPTER ${chapterIndex + 1}",
                      style: const TextStyle(
                        color: orangePrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Chapter Title
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress/Metadata Line
                  Row(
                    children: [
                      const Icon(LucideIcons.bookOpen, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        bookTitle,
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "5 min read", // Mock logic
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(thickness: 1),
                  ),

                  // Chapter Content Blocks
                  ...chapter.content.map((item) => _buildContentBlock(context, item)),
                  
                  const SizedBox(height: 60),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.7),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: const BackButton(color: Colors.black87),
      title: Text(
        "Now Reading",
        style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildContentBlock(BuildContext context, BookContentItemEntity item) {
    if (item.type == 'image') {
      final url = _toFullUrl(item.value);
      print("Original Value: ${item.value}");
       print("ImageUrl: $url");
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  '$url/posts',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Illustration for ${chapter.title}",
              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    // Text Block - Styled for Maximum Readability
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        item.value,
        style: TextStyle(
          fontSize: 18,
          height: 1.8, // Comfortable reading height
          color: Colors.black.withOpacity(0.8),
          letterSpacing: 0.3,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: orangePrimary.withOpacity(0.2)),
            ),
            child: const Icon(LucideIcons.bookOpenCheck, color: orangePrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            "End of Chapter",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            "Thank you for reading $bookTitle",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}