import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String occupation;
  final String bio;
  final int postsCount;
  final String? token;


  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.occupation,
    required this.bio,
    this.token, required this.postsCount,
  });

  // Add this factory
  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      occupation: json['occupation'] ?? '',
      bio: json['bio'] ?? '',
      token: json['token'], postsCount: json['postsCount'] ?? 0, // optional, might be null
    );
  }

  @override
  List<Object?> get props => [name, email, profilePicture, occupation, bio, token, postsCount];
}
