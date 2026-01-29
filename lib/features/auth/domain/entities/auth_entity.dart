import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String name;
  final String email;
  final String? password;
  final String? token;

  const AuthEntity({
    this.authId,
    required this.name,
    required this.email,
    this.password, this.token
  });
  
  @override
  List<Object?> get props => [authId, name, email, password, token];
}
