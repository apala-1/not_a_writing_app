import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String occupation;
  final String bio;
  final String? token;

  ProfileEntity({
    required this.id, required this.name, required this.email, required this.profilePicture, required this.occupation, required this.bio, this.token,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [name, email, profilePicture, occupation, bio, token];
}