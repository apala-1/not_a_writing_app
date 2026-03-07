import 'dart:io';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/book_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';

import '../../domain/entities/book_entity.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksRemoteDataSource remote;
  BooksRepositoryImpl(this.remote);

  @override
  Future<List<BookEntity>> getAllBooks({int skip = 0, int limit = 10}) async {
    final models = await remote.getAllBooks(skip: skip, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
Future<String> uploadChapterImage(File file) => remote.uploadChapterImage(file);

  @override
  Future<List<BookEntity>> getMyBooks() async {
    final models = await remote.getMyBooks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BookEntity> getBookById(String id) async {
    final m = await remote.getBookById(id);
    return m.toEntity();
  }

  @override
  Future<BookEntity> createBook({
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    required File coverPhotoFile,
  }) async {
    final m = await remote.createBook(
      title: title,
      description: description,
      visibility: visibility,
      asDraft: asDraft,
      chapters: chapters,
      coverPhotoFile: coverPhotoFile,
    );
    return m.toEntity();
  }

  @override
  Future<BookEntity> updateBook({
    required String bookId,
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  }) async {
    final m = await remote.updateBook(
      bookId: bookId,
      title: title,
      description: description,
      visibility: visibility,
      asDraft: asDraft,
      chapters: chapters,
      coverPhotoFile: coverPhotoFile,
    );
    return m.toEntity();
  }

  @override
  Future<void> deleteBook(String bookId) => remote.deleteBook(bookId);
}