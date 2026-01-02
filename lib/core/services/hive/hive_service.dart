import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:not_a_writing_app/core/constants/hive_table_constant.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';


final hiveServiceProvider = Provider<HiveService>((ref) { final service = HiveService(); return service; });

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<bool> registerUser(AuthHiveModel model) async {
    if (_authBox.containsKey(model.email)) {
      return false; // duplicate
    }
    await _authBox.put(model.email, model); // ✅ use email as key
    return true;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
  final user = _authBox.get(email);
  if (user != null && user.password == password) {
    final currentUser = AuthHiveModel(
      authId: user.authId,
      fullname: user.fullname,
      email: user.email,
      password: user.password,
    );
    await _authBox.put('currentUser', currentUser); // fresh copy
    return user;
  }
  return null;
}


Future<AuthHiveModel?> getCurrentUser() async {
  return _authBox.get('currentUser'); // ✅ fetch AuthHiveModel
}

Future<void> logoutUser() async {
  await _authBox.delete('currentUser');
}

}
