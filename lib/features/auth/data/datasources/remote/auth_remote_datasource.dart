import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_api_model.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';

// Provider
final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthRemoteDatasource(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);
      
      // Save to session
      await _userSessionService.saveUserSession(authId: (user.authId), email: user.email, name: user.name);
      return user;
    }
    return null;
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

@override
Future<AuthApiModel> register(AuthApiModel user) async {
  final response = await _apiClient.post(
    ApiEndpoints.users,
    data: user.toJson(),
  );

  print('RAW RESPONSE DATA: ${response.data}');

  final body = response.data;

  if (body is Map<String, dynamic> &&
      body['success'] == true &&
      body['data'] is Map<String, dynamic>) {
    return AuthApiModel.fromJson(body['data']);
  }

  throw Exception("Invalid register response: $body");
}


  @override
  Future<AuthHiveModel?> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }
}