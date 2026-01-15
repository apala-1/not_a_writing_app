import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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

class AuthLocalDatasource implements IAuthLocalDatasource {
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
          authId: user.authId!,
          email: user.email,
          name: user.name,
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
Future<AuthHiveModel?> getUserByEmail(String email) async {
  final box = await Hive.openBox<AuthHiveModel>('users');
  try {
    return box.values.firstWhere((user) => user.email == email);
  } catch (e) {
    return null; // return null if not found
  }
}

@override
Future<bool> register(AuthHiveModel user) async {
  try {
    final box = await Hive.openBox<AuthHiveModel>('users');
    await box.put(user.email, user); // store by email as key
    return true; // <--- must return a bool
  } catch (e) {
    return false; // optional: return false if writing fails
  }
}


}