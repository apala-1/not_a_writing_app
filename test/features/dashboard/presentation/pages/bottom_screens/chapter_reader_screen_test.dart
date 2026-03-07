import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chapter_reader_screen.dart';

void main() {
  group('ChapterReaderScreen (widget)', () {
    testWidgets('renders app bar title, chapter label, chapter title and footer',
        (tester) async {
      final chapter = BookChapterEntity(
        title: 'The Beginning',
        content: const [
          BookContentItemEntity(type: 'text', value: 'First paragraph.'),
          BookContentItemEntity(type: 'text', value: 'Second paragraph.'),
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

      // App bar
      expect(find.text('Now Reading'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      // Chapter label and title
      expect(find.text('CHAPTER 1'), findsOneWidget);
      expect(find.text('The Beginning'), findsOneWidget);

      // Book title in metadata row
      expect(find.text('My Book'), findsOneWidget);

      // Content blocks
      expect(find.text('First paragraph.'), findsOneWidget);
      expect(find.text('Second paragraph.'), findsOneWidget);

      // Footer
      expect(find.text('End of Chapter'), findsOneWidget);
      expect(find.text('Thank you for reading My Book'), findsOneWidget);

      // Footer icon
      expect(find.byIcon(LucideIcons.bookOpenCheck), findsOneWidget);
    });

    testWidgets('shows imageOff fallback when Image.network fails',
        (tester) async {
      final chapter = BookChapterEntity(
        title: 'With Image',
        content: const [
          BookContentItemEntity(type: 'image', value: '/uploads/posts/some.jpg'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterReaderScreen(
            bookTitle: 'My Book',
            chapterIndex: 1,
            chapter: chapter,
          ),
        ),
      );

      // Let Image.network attempt to resolve and fail in test environment.
      // Two pumps: one for first frame, one for async image error to hit errorBuilder.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // errorBuilder should show this icon.
      expect(find.byIcon(LucideIcons.imageOff), findsOneWidget);

      // Caption below the image block
      expect(find.text('Illustration for With Image'), findsOneWidget);
    });

    testWidgets('renders both text and image content blocks in order',
        (tester) async {
      final chapter = BookChapterEntity(
        title: 'Mixed',
        content: const [
          BookContentItemEntity(type: 'text', value: 'Before image'),
          BookContentItemEntity(type: 'image', value: '/uploads/posts/a.jpg'),
          BookContentItemEntity(type: 'text', value: 'After image'),
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

      // Text blocks appear
      expect(find.text('Before image'), findsOneWidget);
      expect(find.text('After image'), findsOneWidget);

      // Image caption appears (even if image fails, caption still renders)
      expect(find.text('Illustration for Mixed'), findsOneWidget);

      // Force image to fail and show fallback
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(LucideIcons.imageOff), findsOneWidget);
    });
  });
}