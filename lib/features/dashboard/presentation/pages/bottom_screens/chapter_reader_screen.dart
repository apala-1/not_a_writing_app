import 'package:flutter/material.dart';
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

  String _toFullUrl(String value) {
    final v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('/uploads/')) return '${ApiEndpoints.serverUrl}$v';
    return v; // fallback (in case you store something else)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$bookTitle • Ch ${chapterIndex + 1}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(chapter.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...chapter.content.map((item) {
            if (item.type == 'image') {
              final url = _toFullUrl(item.value);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                item.value,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            );
          }),
        ],
      ),
    );
  }
}