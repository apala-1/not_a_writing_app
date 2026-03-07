import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/update_book_usecase.dart';

class _FakeBookAuthorEntity extends Fake implements BookAuthorEntity {}

class _MockBooksRepository extends Mock implements BooksRepository {}

class _FakeFile extends Fake implements File {}
class _FakeBookChapterEntity extends Fake implements BookChapterEntity {}

void main() {
  late BooksRepository repo;
  late UpdateBookUsecase usecase;

  setUpAll(() {
    registerFallbackValue(_FakeFile());
    registerFallbackValue(_FakeBookAuthorEntity());
    registerFallbackValue(<BookChapterEntity>[_FakeBookChapterEntity()]);
  });

  setUp(() {
    repo = _MockBooksRepository();
    usecase = UpdateBookUsecase(repo);
  });

  test('calls repo.updateBook with coverPhotoFile when provided', () async {
    final cover = File('test_resources/cover.jpg');
    final chapters = <BookChapterEntity>[_FakeBookChapterEntity()];

    final expected = BookEntity(
      id: 'book-1',
      title: 'Updated title',
      description: 'Updated desc',
      visibility: 'private',
      chapters: const [],
      coverPhotoUrl: 'x',
      author: _FakeBookAuthorEntity(),
      coverPhoto: 'image',
      noOfChapters: 0,
      noOfPages: 0,
      status: 'published',
      shareToken: '',
      createdAt: DateTime(2026, 3, 7),
    );

    when(() => repo.updateBook(
          bookId: any(named: 'bookId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          visibility: any(named: 'visibility'),
          asDraft: any(named: 'asDraft'),
          chapters: any(named: 'chapters'),
          coverPhotoFile: any(named: 'coverPhotoFile'),
        )).thenAnswer((_) async => expected);

    final result = await usecase.call(
      bookId: 'book-1',
      title: 'Updated title',
      description: 'Updated desc',
      visibility: 'private',
      asDraft: true,
      chapters: chapters,
      coverPhotoFile: cover,
    );

    expect(result, expected);

    verify(() => repo.updateBook(
          bookId: 'book-1',
          title: 'Updated title',
          description: 'Updated desc',
          visibility: 'private',
          asDraft: true,
          chapters: chapters,
          coverPhotoFile: cover,
        )).called(1);

    verifyNoMoreInteractions(repo);
  });

  test('calls repo.updateBook with coverPhotoFile null when not provided', () async {
    final chapters = <BookChapterEntity>[_FakeBookChapterEntity()];

    final expected = BookEntity(
      id: 'book-1',
      title: 'Updated title',
      description: 'Updated desc',
      visibility: 'private',
      chapters: const [],
      coverPhotoUrl: 'x',
      author: _FakeBookAuthorEntity(),
      coverPhoto: 'image',
      noOfChapters: 0,
      noOfPages: 0,
      status: 'published',
      shareToken: '',
      createdAt: DateTime(2026, 3, 7),
    );

    when(() => repo.updateBook(
          bookId: any(named: 'bookId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          visibility: any(named: 'visibility'),
          asDraft: any(named: 'asDraft'),
          chapters: any(named: 'chapters'),
          coverPhotoFile: any(named: 'coverPhotoFile'),
        )).thenAnswer((_) async => expected);

    final result = await usecase.call(
      bookId: 'book-1',
      title: 'Updated title',
      description: 'Updated desc',
      visibility: 'private',
      asDraft: false,
      chapters: chapters,
      // coverPhotoFile not passed => null
    );

    expect(result, expected);

    verify(() => repo.updateBook(
          bookId: 'book-1',
          title: 'Updated title',
          description: 'Updated desc',
          visibility: 'private',
          asDraft: false,
          chapters: chapters,
          coverPhotoFile: null,
        )).called(1);

    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.updateBook throws', () async {
    final chapters = <BookChapterEntity>[_FakeBookChapterEntity()];

    when(() => repo.updateBook(
          bookId: any(named: 'bookId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          visibility: any(named: 'visibility'),
          asDraft: any(named: 'asDraft'),
          chapters: any(named: 'chapters'),
          coverPhotoFile: any(named: 'coverPhotoFile'),
        )).thenThrow(Exception('fail'));

    expect(
      () => usecase.call(
        bookId: 'book-1',
        title: 'T',
        description: 'D',
        visibility: 'private',
        asDraft: false,
        chapters: chapters,
      ),
      throwsA(isA<Exception>()),
    );
  });
}