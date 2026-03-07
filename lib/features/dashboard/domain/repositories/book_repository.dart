import 'dart:io';
import '../entities/book_entity.dart';

abstract class BooksRepository {
  Future<List<BookEntity>> getAllBooks({int skip, int limit});
  Future<List<BookEntity>> getMyBooks();
  Future<BookEntity> getBookById(String id);

  Future<BookEntity> createBook({
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    required File coverPhotoFile, // REQUIRED by backend
  });

  Future<BookEntity> updateBook({
    required String bookId,
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile, // optional on update
  });

  Future<void> deleteBook(String bookId);

  Future<String> uploadChapterImage(File file);
}