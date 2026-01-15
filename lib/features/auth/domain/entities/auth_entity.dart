import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String name;
  final String email;
  final String? password;

  const AuthEntity({
    this.authId,
    required this.name,
    required this.email,
    this.password
  });
  
  @override
  List<Object?> get props => [authId, name, email, password];
}
