import 'package:not_a_writing_app/features/profile/data/models/profile_hive_model.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';

ProfileHiveModel profileToHive(ProfileEntity e) {
  return ProfileHiveModel(
    id: e.id,
    name: e.name,
    email: e.email,
    profilePicture: e.profilePicture,
    occupation: e.occupation,
    bio: e.bio,
    postsCount: e.postsCount,
    token: e.token,
    cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
  );
}

ProfileEntity profileFromHive(ProfileHiveModel h) {
  return ProfileEntity(
    id: h.id,
    name: h.name,
    email: h.email,
    profilePicture: h.profilePicture,
    occupation: h.occupation,
    bio: h.bio,
    postsCount: h.postsCount,
    token: h.token,
  );
}