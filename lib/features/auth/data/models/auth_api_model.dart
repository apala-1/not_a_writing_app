import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String name;
  final String email;
  final String? password;
  final String? token;

  AuthApiModel({
    required this.name,
    required this.email,
    this.password, this.authId, this.token,
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

  // from JSON
factory AuthApiModel.fromJson(Map<String, dynamic> json) {
  return AuthApiModel(
    authId: json['_id'],       // directly from json
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    token: json['token'],
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