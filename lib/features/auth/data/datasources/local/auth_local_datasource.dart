import '../../models/auth_hive_model.dart';

class AuthLocalDataSource {
  AuthHiveModel? _cachedUser;

  Future<AuthHiveModel> login(String email, String password) async {
    // fake delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK LOGIN
    _cachedUser = AuthHiveModel(
      id: "123",
      name: "Local User",
      email: email,
    );

    return _cachedUser!;
  }

  Future<AuthHiveModel> register(
      String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _cachedUser = AuthHiveModel(
      id: "123",
      name: name,
      email: email,
    );

    return _cachedUser!;
  }

  Future<AuthHiveModel?> getCurrentUser() async {
    return _cachedUser;
  }

  Future<void> logout() async {
    _cachedUser = null;
  }
}
