import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  AuthLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;
  @override 
  Future<AuthHiveModel?> getCurrentUser() async {
    try { 
      final user = await _hiveService.getCurrentUser(); 
      return user; 
    } catch (e) { 
      return null; 
    } 
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
Future<bool> logout() async {
  try {
    await _hiveService.logoutUser();
    return true;
  } catch (e) {
    return false;
  }
}

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
}