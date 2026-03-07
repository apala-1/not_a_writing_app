import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/book_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_book_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/delete_book_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_my_books_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/update_book_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/books_state.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/book_viewmodel.dart';

// Remote DS
final booksRemoteDataSourceProvider = Provider<BooksRemoteDataSource>((ref) {
  final api = ref.read(apiClientProvider);
  return BooksRemoteDataSourceImpl(api);
});

// Repo
final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  return BooksRepositoryImpl(ref.read(booksRemoteDataSourceProvider));
});

// Usecases
final getMyBooksUcProvider = Provider((ref) => GetMyBooksUsecase(ref.read(booksRepositoryProvider)));
final createBookUcProvider = Provider((ref) => CreateBookUsecase(ref.read(booksRepositoryProvider)));
final updateBookUcProvider = Provider((ref) => UpdateBookUsecase(ref.read(booksRepositoryProvider)));
final deleteBookUcProvider = Provider((ref) => DeleteBookUsecase(ref.read(booksRepositoryProvider)));

// VM
final booksDashboardVmProvider = StateNotifierProvider<BooksDashboardVm, BooksDashboardState>((ref) {
  return BooksDashboardVm(
    getMyBooks: ref.read(getMyBooksUcProvider),
    deleteBook: ref.read(deleteBookUcProvider),
  )..load();
});

final bookByIdProvider = FutureProvider.family<BookEntity, String>((ref, bookId) async {
  final repo = ref.read(booksRepositoryProvider);
  return repo.getBookById(bookId);
});