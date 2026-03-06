import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String name;
  final String email;
  final String? password;
  final String? token;
  final String? profilePicture;

  AuthApiModel({
    required this.name,
    required this.email,
    this.password, this.authId, this.token, this.profilePicture,
  });

  // to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
    };
    if (password != null) {
      data['password'] = password;
    }
    return data;
  }

 factory AuthApiModel.fromJsonRegister(Map<String, dynamic> json) {
  print('Json:$json');
  final data = json as Map<String, dynamic>? ?? json['data'] as Map<String, dynamic>?;
  if (data == null) {
    throw Exception('Auth response missing data');
  }
  // Some responses wrap user inside 'user', others just have data directly
  final user = data['user'] as Map<String, dynamic>? ?? data;
  print("User: $user");

  return AuthApiModel(
    authId: data['_id'] ?? data['id'] ?? data['authId'],
    name: user['name'] ?? '',
    email: user['email'] ?? '',
    password: user['password'],
    token: user['token'],
    profilePicture: user['profilePicture'],
  );
}

factory AuthApiModel.fromJsonLogin(Map<String, dynamic> json) {
  print('Json:$json');
  final data = json['data'] as Map<String, dynamic>?;

  if (data == null) {
    throw Exception('Auth response missing data');
  }

  // user info might be nested inside 'user' (login) or directly (register)
  final user = data['user'] as Map<String, dynamic>? ?? data;

  return AuthApiModel(
    authId: user['_id'] ?? '',                   // always inside 'user' or 'data'
    name: user['name'] ?? '',
    email: user['email'] ?? '',
    password: user['password'],
    token: data['token'] as String?,             // always at top level of data
    profilePicture: user['profilePicture'],
  );
}




  // to Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      name: name,
      email: email,
      token: token,
    );
  }

  // from Entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
    );
  }

  // to EntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}