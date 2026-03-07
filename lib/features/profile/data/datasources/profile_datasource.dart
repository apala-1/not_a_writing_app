import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_hive_model.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';

abstract interface class IProfileLocalDatasource{
  Future<ProfileHiveModel> fetchProfile();
  Future<ProfileHiveModel> updateProfile(ProfileHiveModel model);
  Future<String> uploadProfilePicture(XFile image);
  // Future<void> updatePassword()
}

abstract interface class IProfileRemoteDatasource{
  Future<ProfileApiModel> fetchProfile();
  Future<ProfileApiModel> updateProfile(UpdateProfileParams params);
  Future<String> uploadProfilePicture(XFile image);
  // Future<void> updatePassword()
  Future<ProfileApiModel> fetchProfileById(String userId);
  Future<List<dynamic>> getLikedPostsRaw();
  Future<List<dynamic>> getSavedPostsRaw();
}