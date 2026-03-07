import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/book_viewmodel.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/presentation/state/books_state.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/delete_book_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_my_books_usecase.dart';

class _MockGetMyBooksUsecase extends Mock implements GetMyBooksUsecase {}

class _MockDeleteBookUsecase extends Mock implements DeleteBookUsecase {}

void main() {
  late GetMyBooksUsecase getMyBooks;
  late DeleteBookUsecase deleteBook;
  late BooksDashboardVm vm;

  // Use a helper to create books without repeating yourself
  BookEntity _book(String id) => BookEntity(
        id: id,
        title: 't',
        description: 'd',
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
      );

  setUp(() {
    getMyBooks = _MockGetMyBooksUsecase();
    deleteBook = _MockDeleteBookUsecase();
    vm = BooksDashboardVm(getMyBooks: getMyBooks, deleteBook: deleteBook);
  });

  test('initial state is BooksDashboardState.initial()', () {
    expect(vm.state, BooksDashboardState.initial());
  });

  test('load(): sets loading true then sets books on success', () async {
    final books = <BookEntity>[_book('b1'), _book('b2')];

    when(() => getMyBooks()).thenAnswer((_) async => books);

    // act
    final future = vm.load();

    // immediate state change (sync)
    expect(vm.state.loading, true);
    expect(vm.state.error, isNull);

    await future;

    // final state
    expect(vm.state.loading, false);
    expect(vm.state.error, isNull);
    expect(vm.state.books, books);

    verify(() => getMyBooks()).called(1);
    verifyNoMoreInteractions(getMyBooks);
    verifyNoMoreInteractions(deleteBook);
  });

  test('load(): sets error when getMyBooks throws', () async {
    when(() => getMyBooks()).thenThrow(Exception('boom'));

    await vm.load();

    expect(vm.state.loading, false);
    expect(vm.state.books, isEmpty);
    expect(vm.state.error, contains('boom'));

    verify(() => getMyBooks()).called(1);
    verifyNoMoreInteractions(getMyBooks);
    verifyNoMoreInteractions(deleteBook);
  });

  test('onDelete(): calls deleteBook and removes book from state on success', () async {
    // arrange: seed initial state with books
    vm.state = vm.state.copyWith(books: [_book('b1'), _book('b2')]);

    when(() => deleteBook('b1')).thenAnswer((_) async {});

    // act
    await vm.onDelete('b1');

    // assert
    expect(vm.state.books.map((b) => b.id).toList(), ['b2']);
    expect(vm.state.error, isNull);

    verify(() => deleteBook('b1')).called(1);
    verifyNoMoreInteractions(deleteBook);
    verifyNoMoreInteractions(getMyBooks);
  });

  test('onDelete(): sets error when deleteBook throws and does not change books', () async {
    vm.state = vm.state.copyWith(books: [_book('b1'), _book('b2')]);

    when(() => deleteBook('b1')).thenThrow(Exception('delete failed'));

    await vm.onDelete('b1');

    expect(vm.state.books.map((b) => b.id).toList(), ['b1', 'b2']);
    expect(vm.state.error, contains('delete failed'));

    verify(() => deleteBook('b1')).called(1);
    verifyNoMoreInteractions(deleteBook);
    verifyNoMoreInteractions(getMyBooks);
  });
}