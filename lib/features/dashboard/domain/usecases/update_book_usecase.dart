import 'dart:io';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';

import '../entities/book_entity.dart';

class UpdateBookUsecase {
  final BooksRepository repo;
  UpdateBookUsecase(this.repo);

  Future<BookEntity> call({
    required String bookId,
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  }) {
    return repo.updateBook(
      bookId: bookId,
      title: title,
      description: description,
      visibility: visibility,
      asDraft: asDraft,
      chapters: chapters,
      coverPhotoFile: coverPhotoFile,
    );
  }
}