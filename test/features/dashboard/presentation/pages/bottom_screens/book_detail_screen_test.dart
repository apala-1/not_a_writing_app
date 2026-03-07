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
}