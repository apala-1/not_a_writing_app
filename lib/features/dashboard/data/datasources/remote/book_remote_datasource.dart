import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/book_api_model.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

abstract class BooksRemoteDataSource {
  Future<List<BookApiModel>> getAllBooks({int skip, int limit});
  Future<List<BookApiModel>> getMyBooks();
  Future<BookApiModel> getBookById(String id);

  Future<BookApiModel> createBook({
    required String title,
    required String description,
    required String visibility, // public/private/link
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  });

  Future<BookApiModel> updateBook({
    required String bookId,
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  });

  Future<void> deleteBook(String bookId);

  Future<String> uploadChapterImage(File file);
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  final ApiClient api;
  BooksRemoteDataSourceImpl(this.api);

  dynamic _unwrap(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) return body['data'];
    return body;
  }

  List<Map<String, dynamic>> _chaptersToJson(List<BookChapterEntity> chapters) {
  return chapters
      .map((c) {
        final cleanedContent = c.content
            .where((i) => i.value.trim().isNotEmpty) // ✅ remove empty blocks
            .map((i) => {'type': i.type, 'value': i.value})
            .toList();

        return {
          'title': c.title.trim().isEmpty ? 'Untitled Chapter' : c.title.trim(),
          'content': cleanedContent,
        };
      })
      // ✅ also ensure each chapter has at least one content item
      .map((c) {
        final content = (c['content'] as List);
        if (content.isEmpty) {
          c['content'] = [
            {'type': 'text', 'value': ' '} // or throw; see below
          ];
        }
        return c;
      })
      .toList();
}

  @override
  Future<List<BookApiModel>> getAllBooks({int skip = 0, int limit = 10}) async {
    final res = await api.dio.get(ApiEndpoints.getAllBooks(), queryParameters: {'skip': skip, 'limit': limit});
    final data = _unwrap(res);
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(BookApiModel.fromJson).toList();
  }

  @override
  Future<List<BookApiModel>> getMyBooks() async {
    final res = await api.dio.get(ApiEndpoints.getMyBooks());
    final data = _unwrap(res);
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(BookApiModel.fromJson).toList();
  }

  @override
  Future<BookApiModel> getBookById(String id) async {
    final res = await api.dio.get(ApiEndpoints.getBookById(id));
    final data = _unwrap(res) as Map<String, dynamic>;
    return BookApiModel.fromJson(data);
  }

  Future<String> uploadChapterImage(File file) async {
  final form = FormData.fromMap({
    'image': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
  });

  final res = await api.dio.post(
    ApiEndpoints.uploadBookChapterImage(),
    data: form,
    options: Options(contentType: 'multipart/form-data'),
  );

  final body = res.data;
  final data = (body is Map<String, dynamic> && body.containsKey('data')) ? body['data'] : body;

  // expecting { url: "/uploads/books/chapters/xxx.jpg" }
  final url = (data['url'] ?? '').toString();
  if (url.isEmpty) throw Exception('Upload failed: no url returned');
  return url;
}

  @override
  Future<BookApiModel> createBook({
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  }) async {
    final form = FormData();

    form.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('visibility', visibility),
      MapEntry('status', asDraft ? 'draft' : 'published'),
      // If backend needs coverPhoto enum:
      MapEntry('coverPhoto', 'image'),
      // chapters as JSON string
      MapEntry('chapters', jsonEncode(_chaptersToJson(chapters))),
    ]);

    if (coverPhotoFile != null) {
      form.files.add(
        MapEntry(
          'coverPhoto',
          await MultipartFile.fromFile(coverPhotoFile.path, filename: coverPhotoFile.uri.pathSegments.last),
        ),
      );
    }

    final res = await api.dio.post(ApiEndpoints.createBook(), data: form);
    final data = _unwrap(res) as Map<String, dynamic>;
    return BookApiModel.fromJson(data);
  }

  @override
  Future<BookApiModel> updateBook({
    required String bookId,
    required String title,
    required String description,
    required String visibility,
    required bool asDraft,
    required List<BookChapterEntity> chapters,
    File? coverPhotoFile,
  }) async {
    final form = FormData();

    form.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('visibility', visibility),
      MapEntry('status', asDraft ? 'draft' : 'published'),
      MapEntry('coverPhoto', 'image'),
      MapEntry('chapters', jsonEncode(_chaptersToJson(chapters))),
    ]);

    if (coverPhotoFile != null) {
      form.files.add(
        MapEntry(
          'coverPhoto',
          await MultipartFile.fromFile(coverPhotoFile.path, filename: coverPhotoFile.uri.pathSegments.last),
        ),
      );
    }

    final res = await api.dio.put(ApiEndpoints.updateBook(bookId), data: form);
    final data = _unwrap(res) as Map<String, dynamic>;
    return BookApiModel.fromJson(data);
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await api.dio.delete(ApiEndpoints.deleteBook(bookId));
  }
}