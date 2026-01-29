import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';

/// Provider
final profileRemoteProvider = Provider<IProfileRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return ProfileRemoteDatasource(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

class ProfileRemoteDatasource implements IProfileRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  ProfileRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<ProfileApiModel> fetchProfile() async {
    final token = await _userSessionService.getUserToken();
    if (token == null) throw Exception("No token found");

    final response = await _apiClient.get(
      ApiEndpoints.userMe,
    );

    if (response.statusCode == 200) {
    // response.data['data'] is already a Map<String, dynamic>
    final profileData = response.data['data'] as Map<String, dynamic>;
    return ProfileApiModel.fromJson(profileData);
  } else {
    throw Exception("Failed to fetch profile");
  }
  }

  @override
Future<ProfileApiModel> updateProfile(UpdateProfileParams params) async {
  final formData = FormData();

  if (params.name != null) {
    formData.fields.add(MapEntry('name', params.name!));
  }
  if (params.email != null) {
    formData.fields.add(MapEntry('email', params.email!));
  }
  if (params.password != null) {
    formData.fields.add(MapEntry('password', params.password!));
  }
  if (params.bio != null) {
    formData.fields.add(MapEntry('bio', params.bio!));
  }
  if (params.occupation != null) {
    formData.fields.add(MapEntry('occupation', params.occupation!));
  }

  if (params.profilePicture != null) {
    formData.files.add(
      MapEntry(
        'profilePicture',
        await MultipartFile.fromFile(params.profilePicture!),
      ),
    );
  }

  final response = await _apiClient.put(
    '${ApiEndpoints.users}/${params.userId}',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer ${params.token}',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

  if (response.statusCode == 200) {
    return ProfileApiModel.fromJson(response.data['data']);
  } else {
    throw Exception('Profile update failed');
  }
}

  @override
  Future<String> uploadProfilePicture(XFile image) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }
}
