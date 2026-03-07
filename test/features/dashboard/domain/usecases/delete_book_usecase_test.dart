import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/delete_book_usecase.dart';

class _MockBooksRepository extends Mock implements BooksRepository {}

void main() {
  late BooksRepository repo;
  late DeleteBookUsecase usecase;

  setUp(() {
    repo = _MockBooksRepository();
    usecase = DeleteBookUsecase(repo);
  });

  test('calls repo.deleteBook with the same bookId', () async {
    // arrange
    when(() => repo.deleteBook(any())).thenAnswer((_) async {});

    // act
    await usecase.call('book-1');

    // assert
    verify(() => repo.deleteBook('book-1')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.deleteBook throws', () async {
    // arrange
    when(() => repo.deleteBook(any())).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call('book-1'),
      throwsA(isA<Exception>()),
    );
  });
}