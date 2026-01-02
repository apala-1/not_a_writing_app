import '../../domain/entities/auth_entity.dart';

class AuthHiveModel extends AuthEntity {
  AuthHiveModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory AuthHiveModel.fromJson(Map<String, dynamic> json) {
    return AuthHiveModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
