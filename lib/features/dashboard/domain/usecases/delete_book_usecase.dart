
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';

class DeleteBookUsecase {
  final BooksRepository repo;
  DeleteBookUsecase(this.repo);

  Future<void> call(String bookId) => repo.deleteBook(bookId);
}