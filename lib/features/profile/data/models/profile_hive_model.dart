import 'package:hive/hive.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 1)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String profilePicture;

  @HiveField(4)
  String bio;

  @HiveField(5)
  String occupation;

  ProfileHiveModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.bio,
    required this.occupation,
  });

  ProfileEntity toEntity() => ProfileEntity(id: id, name: name, email: email, profilePicture: profilePicture, occupation: occupation, bio: bio);
}