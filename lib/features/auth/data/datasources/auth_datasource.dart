import '../models/auth_hive_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthHiveModel> login(String email, String password);
  Future<AuthHiveModel> register(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthHiveModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    return AuthHiveModel(
      id: "1",
      name: "Demo User",
      email: email,
    );
  }

  @override
  Future<AuthHiveModel> register(
      String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    return AuthHiveModel(
      id: "2",
      name: name,
      email: email,
    );
  }
}
