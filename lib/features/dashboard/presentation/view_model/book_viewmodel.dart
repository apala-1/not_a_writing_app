import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/books_state.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_my_books_usecase.dart';

class BooksDashboardVm extends StateNotifier<BooksDashboardState> {
  final GetMyBooksUsecase getMyBooks;
  final DeleteBookUsecase deleteBook;

  BooksDashboardVm({
    required this.getMyBooks,
    required this.deleteBook,
  }) : super(BooksDashboardState.initial());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await getMyBooks();
      state = state.copyWith(loading: false, books: data);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> onDelete(String bookId) async {
    try {
      await deleteBook(bookId);
      state = state.copyWith(books: state.books.where((b) => b.id != bookId).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}