import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chapter_reader_screen.dart';

void main() {
  testWidgets('renders app bar title, chapter title, and text blocks', (tester) async {
    final chapter = BookChapterEntity(
      title: 'Chapter One',
      content: const [
        BookContentItemEntity(type: 'text', value: 'Hello world'),
        BookContentItemEntity(type: 'text', value: 'Second paragraph'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChapterReaderScreen(
          bookTitle: 'My Book',
          chapterIndex: 0,
          chapter: chapter,
        ),
      ),
    );

    expect(find.text('My Book • Ch 1'), findsOneWidget);
    expect(find.text('Chapter One'), findsOneWidget);

    expect(find.text('Hello world'), findsOneWidget);
    expect(find.text('Second paragraph'), findsOneWidget);
  });

  testWidgets('renders image blocks as Image.network widgets', (tester) async {
    final chapter = BookChapterEntity(
      title: 'Chapter With Image',
      content: const [
        BookContentItemEntity(type: 'image', value: 'https://example.com/a.png'),
        BookContentItemEntity(type: 'text', value: 'after image'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChapterReaderScreen(
          bookTitle: 'My Book',
          chapterIndex: 2,
          chapter: chapter,
        ),
      ),
    );

    expect(find.text('My Book • Ch 3'), findsOneWidget);
    expect(find.text('Chapter With Image'), findsOneWidget);

    // One Image widget from Image.network
    expect(find.byType(Image), findsOneWidget);

    // Still shows text after image
    expect(find.text('after image'), findsOneWidget);
  });

  testWidgets('image widget shows broken_image icon when image fails to load', (tester) async {
    // We can't (and shouldn't) do real network in widget tests.
    // Use a clearly-invalid URL so Image.network will fail and errorBuilder is used.
    final chapter = BookChapterEntity(
      title: 'Broken Image',
      content: const [
        BookContentItemEntity(type: 'image', value: 'http://invalid.invalid/notfound.png'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChapterReaderScreen(
          bookTitle: 'My Book',
          chapterIndex: 0,
          chapter: chapter,
        ),
      ),
    );

    // Let image attempt resolve and error.
    // (In widget tests, the network image will typically fail quickly.)
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}