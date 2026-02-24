import 'package:not_a_writing_app/features/dashboard/data/datasources/book_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/book_repository.dart';
import 'package:image_picker/image_picker.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remote;

  BookRepositoryImpl(this.remote);

  Future<BookEntity> createBookMultipart({
    required String title,
    required String description,
    required List<Map<String, dynamic>> chapters,
    required XFile coverPhoto,
  }) async {
    final model = await remote.createBookMultipart(
      title: title,
      description: description,
      chapters: chapters,
      coverPhoto: coverPhoto,
    );
    return model.toEntity();
  }
}