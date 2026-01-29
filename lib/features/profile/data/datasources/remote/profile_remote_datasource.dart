import 'package:cross_file/src/types/interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';

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
  Future<ProfileApiModel> fetchProfile() {
    // TODO: implement fetchProfile
    throw UnimplementedError();
  }

  @override
  Future<ProfileApiModel> updateProfile(ProfileApiModel model) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<String> uploadProfilePicture(XFile image) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }
}
