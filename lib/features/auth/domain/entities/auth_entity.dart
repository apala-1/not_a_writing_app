import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullname;
  final String email;
  final String? password;

  const AuthEntity({
    this.authId,
    required this.fullname,
    required this.email,
    this.password
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [authId, fullname, email, password];
}
