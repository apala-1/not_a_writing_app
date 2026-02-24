import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/book_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/book_api_model.dart';
import 'package:image_picker/image_picker.dart';

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final UserSessionService _userSessionService;

  BookRemoteDataSourceImpl({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  Future<String> _getToken() async => await _userSessionService.getUserToken() ?? '';

  Future<BookApiModel> createBookMultipart({
  required String title,
  required String description,
  required List<Map<String, dynamic>> chapters,
  required XFile coverPhoto,
}) async {
  final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.createBook()}');

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer ${await _getToken()}'
    ..fields['title'] = title
    ..fields['description'] = description
    ..fields['chapters'] = jsonEncode(chapters) // chapters must be JSON string
    ..files.add(await http.MultipartFile.fromPath(
      'coverPhoto',
      coverPhoto.path,
      contentType: MediaType('image', coverPhoto.path.split('.').last),
    ));

  final streamedResponse = await request.send();
  final res = await http.Response.fromStream(streamedResponse);

  if (res.statusCode != 201) {
    throw Exception('Failed to create book: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'];
  return BookApiModel.fromJson(data);
}

}