import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

class BooksDashboardState {
  final bool loading;
  final String? error;
  final List<BookEntity> books;

  const BooksDashboardState({
    required this.loading,
    required this.books,
    this.error,
  });

  factory BooksDashboardState.initial() => const BooksDashboardState(loading: false, books: []);
  BooksDashboardState copyWith({bool? loading, String? error, List<BookEntity>? books}) {
    return BooksDashboardState(
      loading: loading ?? this.loading,
      error: error,
      books: books ?? this.books,
    );
  }
}