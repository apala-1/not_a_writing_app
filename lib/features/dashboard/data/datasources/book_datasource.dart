import 'package:not_a_writing_app/features/dashboard/data/models/book_api_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/book_remote_datasource.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';

final bookRemoteDatasourceProvider = Provider<BookRemoteDataSource>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);

  return BookRemoteDataSourceImpl(
    userSessionService: userSessionService,
  );
});


abstract class BookRemoteDataSource {
  Future<BookApiModel> createBookMultipart({
    required String title,
    required String description,
    required List<Map<String, dynamic>> chapters,
    required XFile coverPhoto,
  });
}