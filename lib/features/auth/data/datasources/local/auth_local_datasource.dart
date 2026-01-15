import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/hive/hive_service.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final userSessionService = ref.watch(userSessionServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService, userSessionService: userSessionService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({required HiveService hiveService, required UserSessionService userSessionService})
      : _hiveService = hiveService, _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return await _hiveService.getCurrentUser();
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null) {
        // Save session data
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullname: user.fullname,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
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