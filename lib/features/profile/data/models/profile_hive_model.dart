import 'package:hive/hive.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: 40)
class ProfileHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String profilePicture;

  @HiveField(4)
  final String occupation;

  @HiveField(5)
  final String bio;

  @HiveField(6)
  final int postsCount;

  @HiveField(7)
  final String? token;

  @HiveField(8)
  final int cachedAtMillis;

  const ProfileHiveModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.occupation,
    required this.bio,
    required this.postsCount,
    required this.token,
    required this.cachedAtMillis,
  });
}