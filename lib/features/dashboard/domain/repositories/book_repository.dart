import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/book_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/book_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl(ref.read(bookRemoteDatasourceProvider));
});

abstract class BookRepository {
  Future<BookEntity> createBookMultipart({
    required String title,
    required String description,
    required List<Map<String, dynamic>> chapters,
    required XFile coverPhoto,
  });
}