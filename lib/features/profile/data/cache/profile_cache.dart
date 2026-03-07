import 'package:hive/hive.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_hive_model.dart';

class ProfileCache {
  static const String boxName = 'profile_cache_v1';

  Future<Box<ProfileHiveModel>> _box() async {
    return Hive.openBox<ProfileHiveModel>(boxName);
  }

  Future<ProfileHiveModel?> readByUserId(String userId) async {
    final box = await _box();
    return box.get(userId);
  }

  Future<void> write(ProfileHiveModel model) async {
    final box = await _box();
    await box.put(model.id, model);
  }
}