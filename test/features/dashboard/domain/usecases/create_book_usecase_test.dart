import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_book_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

// 1) Mock
class _MockBooksRepository extends Mock implements BooksRepository {}

// 2) Fallbacks (Mocktail needs these for non-primitive args used with any())
class _FakeFile extends Fake implements File {}
class _FakeBookChapterEntity extends Fake implements BookChapterEntity {}

void main() {
  late BooksRepository repo;
  late CreateBookUsecase usecase;

  setUpAll(() {
    registerFallbackValue(_FakeFile());
    registerFallbackValue(<BookChapterEntity>[_FakeBookChapterEntity()]);
  });

  setUp(() {
    repo = _MockBooksRepository();
    usecase = CreateBookUsecase(repo);
  });

  test('calls repo.createBook with the same params and returns BookEntity', () async {
    // arrange
    final cover = File('test_resources/cover.jpg'); // doesn't need to exist (not read)
    final chapters = <BookChapterEntity>[
      // Use your real constructor if you have one; otherwise Fake is ok if not used.
      _FakeBookChapterEntity(),
    ];

    final expected = BookEntity(
      id: 'book-1',
      title: 'My Book',
      description: 'Desc',
      visibility: 'private',
      // add other required fields...
      chapters: const [],
      coverPhotoUrl: 'x',
author: null, coverPhoto: '', noOfChapters: 0, noOfPages: 0, status: '', shareToken: '', createdAt: null,
    );

    when(() => repo.createBook(
          title: any(named: 'title'),
          description: any(named: 'description'),
          visibility: any(named: 'visibility'),
          asDraft: any(named: 'asDraft'),
          chapters: any(named: 'chapters'),
          coverPhotoFile: any(named: 'coverPhotoFile'),
        )).thenAnswer((_) async => expected);

    // act
    final result = await usecase.call(
      title: 'My Book',
      description: 'Desc',
      visibility: 'private',
      asDraft: true,
      chapters: chapters,
      coverPhotoFile: cover,
    );

    // assert (return)
    expect(result, expected);

    // assert (forwarded call)
    verify(() => repo.createBook(
          title: 'My Book',
          description: 'Desc',
          visibility: 'private',
          asDraft: true,
          chapters: chapters,
          coverPhotoFile: cover,
        )).called(1);

    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.createBook throws', () async {
    // arrange
    final cover = File('test_resources/cover.jpg');
    final chapters = <BookChapterEntity>[_FakeBookChapterEntity()];

    when(() => repo.createBook(
          title: any(named: 'title'),
          description: any(named: 'description'),
          visibility: any(named: 'visibility'),
          asDraft: any(named: 'asDraft'),
          chapters: any(named: 'chapters'),
          coverPhotoFile: any(named: 'coverPhotoFile'),
        )).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call(
        title: 'T',
        description: 'D',
        visibility: 'private',
        asDraft: false,
        chapters: chapters,
        coverPhotoFile: cover,
      ),
      throwsA(isA<Exception>()),
    );
  });
}