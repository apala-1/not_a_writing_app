import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_detail_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chapter_reader_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';

void main() {
  const bookId = 'b1';

  testWidgets('shows loader when bookByIdProvider is loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookByIdProvider(bookId).overrideWith((ref) async {
            // never completes => AsyncLoading
            return Completer<BookEntity>().future;
          }),
        ],
        child: const MaterialApp(
          home: BookDetailScreen(bookId: bookId),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders book details + chapters; tapping chapter navigates to ChapterReaderScreen', (tester) async {
    final book = _fakeBook(
      id: bookId,
      title: 'My Book',
      description: 'Hello description',
      chapters: [
        _fakeChapter(title: 'Chapter 1', blocks: 2),
        _fakeChapter(title: 'Chapter 2', blocks: 1),
      ],
      shareToken: 'tok123',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookByIdProvider(bookId).overrideWith((ref) async => book),
        ],
        child: const MaterialApp(
          home: BookDetailScreen(bookId: bookId),
        ),
      ),
    );

    await tester.pump(); // start provider
    await tester.pumpAndSettle(); // data arrives, UI builds

    // Header + description
    expect(find.text('My Book'), findsOneWidget);
    expect(find.text('Hello description'), findsOneWidget);

    // Chips
    expect(find.textContaining('Status:'), findsOneWidget);
    expect(find.textContaining('Visibility:'), findsOneWidget);
    expect(find.text('Chapters: 2'), findsOneWidget);
    expect(find.text('Token: tok123'), findsOneWidget);

    // Chapter tiles
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('2 blocks'), findsOneWidget);
    expect(find.text('1 blocks'), findsOneWidget);

    // Tap Chapter 1 => navigates
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    expect(find.byType(ChapterReaderScreen), findsOneWidget);
  });
}

/// ---------------------------------------------------------------------------
/// Helpers
/// NOTE: you must adjust these constructors to match your real entities.
/// Paste BookEntity + BookChapterEntity definitions if you want me to
/// rewrite these exactly for your project.
/// ---------------------------------------------------------------------------

BookEntity _fakeBook({
  required String id,
  required String title,
  required String description,
  required List<BookChapterEntity> chapters,
  String status = 'draft',
  String visibility = 'private',
  String coverPhotoUrl = 'https://example.com/cover.png',
  int noOfPages = 10,
  int noOfChapters = 2,
  String? shareToken,
}) {
  return BookEntity(
    id: id,
    title: title,
    description: description,
    status: status,
    visibility: visibility,
    coverPhotoUrl: coverPhotoUrl,
    noOfPages: noOfPages,
    noOfChapters: noOfChapters,
    shareToken: shareToken,
    chapters: chapters,
    author: null, coverPhoto: '', createdAt: null,
  );
}

BookChapterEntity _fakeChapter({required String title, required int blocks}) {
  return BookChapterEntity(
    title: title,
    content: List.generate(
      blocks,
      (_) => const BookContentItemEntity(type: 'text', value: 'x'),
    ),
  );
}