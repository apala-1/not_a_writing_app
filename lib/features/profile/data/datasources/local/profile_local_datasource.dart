import 'package:cross_file/src/types/interface.dart';
import 'package:hive/hive.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_hive_model.dart';

class ProfileLocalDatasource implements IProfileLocalDatasource {
  final Box<ProfileHiveModel> box;

  ProfileLocalDatasource(this.box);

  @override
  Future<bool> saveProfile(ProfileHiveModel model) async {
    await box.put(model.id, model);
    return true;
  }

  @override
  Future<ProfileHiveModel?> getProfile(String userId) async {
    return box.get(userId);
  }

  @override
  Future<bool> deleteProfile(String userId) async {
    await box.delete(userId);
    return true;
  }

  @override
  Future<ProfileHiveModel> fetchProfile() {
    // TODO: implement fetchProfile
    throw UnimplementedError();
  }

  @override
  Future<ProfileHiveModel> updateProfile(ProfileHiveModel model) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<String> uploadProfilePicture(XFile image) {
    // TODO: implement uploadProfilePicture
    throw UnimplementedError();
  }
}
