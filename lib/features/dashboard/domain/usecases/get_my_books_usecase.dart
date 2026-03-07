import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';

import '../entities/book_entity.dart';

class GetMyBooksUsecase {
  final BooksRepository repo;
  GetMyBooksUsecase(this.repo);

  Future<List<BookEntity>> call() => repo.getMyBooks();
}