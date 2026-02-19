import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';

class ProfileApiModel extends ProfileEntity {
  ProfileApiModel({required super.id, required super.name, required super.email, required super.profilePicture, required super.occupation, required super.bio, super.token, required super.postsCount});

  Map<String, dynamic> toJson({String? password}) {
    return {
      "name": name,
      "email": email,
      "profilePicture": profilePicture,
      "occupation": occupation,
      "bio": bio,
      if(password != null) "password": password,
      "token": token,
      "postsCount": postsCount,
    };
  }

    factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'] ?? 'default-picture.png',
      occupation: json['occupation'] ?? '',
      bio: json['bio'] ?? '', token: json['token'], postsCount: json['postsCount'] ?? 0,
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