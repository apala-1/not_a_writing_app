import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:not_a_writing_app/core/services/hive/hive_service.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;
  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return await _hiveService.getCurrentUser();
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return await _hiveService.loginUser(email, password);
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logoutUser();
    return true;
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    return await _hiveService.registerUser(model);
  }
}