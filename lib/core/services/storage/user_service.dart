import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = Dio();
  final session = ref.read(userSessionServiceProvider);
  return UserService(dio, session);
});

class UserService {
  final Dio _dio;
  final UserSessionService _session;

  UserService(this._dio, this._session);

  Future<String> uploadProfileImage(XFile image) async {
    final token = _session.getUserToken();
    if (token == null || token.isEmpty) {
      throw Exception("User not logged in");
    }

    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(image.path,
          filename: image.name),
    });

    final response = await _dio.put(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.updateMe}',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['data']['profilePicture']; // or whatever your API returns
    } else {
      throw Exception('Profile image upload failed: ${response.statusCode}');
    }
  }
}