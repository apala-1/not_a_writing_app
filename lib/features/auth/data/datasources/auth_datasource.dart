import 'package:not_a_writing_app/features/auth/data/models/auth_api_model.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> logout();
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> register(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getCurrentUser();
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
  Future<AuthApiModel?> loginWithGoogle(String idToken);
}