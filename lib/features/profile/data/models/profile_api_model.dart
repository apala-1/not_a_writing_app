import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';

class ProfileApiModel{
  ProfileApiModel({required this.id, required this.name, required this.email, required this.profilePicture, required this.occupation, required this.bio, this.token, required this.postsCount});

  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String occupation;
  final String bio;
  final String? token;
  final int postsCount;
  
Map<String, dynamic> toJson({String? password}) {
  return {
    "name": name,
    "email": email,
    "profilePicture": profilePicture,
    "occupation": occupation,
    "bio": bio,
    if (password != null) "password": password,
    if (token != null) "token": token,
    "postsCount": postsCount,
  };
}

    factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
  return ProfileApiModel(
    id: (json['_id'] ?? json['userId'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    profilePicture: (json['profilePicture'] ?? 'default-picture.png').toString(),
    occupation: (json['occupation'] ?? '').toString(),
    bio: (json['bio'] ?? '').toString(),
    token: json['token']?.toString(),
    postsCount: (json['postsCount'] is int)
        ? json['postsCount']
        : int.tryParse((json['postsCount'] ?? 0).toString()) ?? 0,
  );
}

  factory ProfileApiModel.fromParams(UpdateProfileParams params) {
  return ProfileApiModel(
    id: params.userId,
    name: params.name ?? '',
    email: params.email ?? '',
    profilePicture: params.profilePicture ?? 'default-picture.png',
    occupation: params.occupation ?? '',
    bio: params.bio ?? '', token: params.token!, postsCount: params.postsCount ?? 0,
  );
}

 /// Convert API model to domain entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      profilePicture: profilePicture,
      occupation: occupation,
      bio: bio,
      token: token, postsCount: postsCount,
    );
  }

  /// Convert domain entity back to API model
  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      profilePicture: entity.profilePicture,
      occupation: entity.occupation,
      bio: entity.bio,
      token: entity.token,
      postsCount: entity.postsCount,
    );
  }


}