import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_my_books_usecase.dart';

class _MockBooksRepository extends Mock implements BooksRepository {}

void main() {
  late BooksRepository repo;
  late GetMyBooksUsecase usecase;

  setUp(() {
    repo = _MockBooksRepository();
    usecase = GetMyBooksUsecase(repo);
  });

  test('calls repo.getMyBooks and returns list of BookEntity', () async {
    // arrange
    final books = <BookEntity>[
      BookEntity(
        id: 'b1',
        title: 'Book 1',
        description: 'Desc',
        visibility: 'private',
        chapters: const [],
        coverPhotoUrl: 'x',
        author: null, // BookAuthorEntity? in your project
        coverPhoto: 'image',
        noOfChapters: 0,
        noOfPages: 0,
        status: 'published',
        shareToken: '',
        createdAt: DateTime(2026, 3, 7),
      ),
    ];

    when(() => repo.getMyBooks()).thenAnswer((_) async => books);

    // act
    final result = await usecase.call();

    // assert
    expect(result, books);
    verify(() => repo.getMyBooks()).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.getMyBooks throws', () async {
    // arrange
    when(() => repo.getMyBooks()).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call(),
      throwsA(isA<Exception>()),
    );
  });
}