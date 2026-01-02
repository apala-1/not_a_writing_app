import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:not_a_writing_app/core/constants/hive_table_constant.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) { final service = HiveService(); return service; });

class HiveService {
  // init
  Future<void> init() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
  }

  // Register Adapters
  void _registerAdapter(){
    if(!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ====================AUTH QUERIES====================

  Box<AuthHiveModel> get _authBox =>
    Hive.box<AuthHiveModel>(HiveTableConstant.authTable);


  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // Login
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where((user) => user.email == email && user.password == password);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // logout
  Future<void> logoutUser() async {
  final box = Hive.box<AuthHiveModel>('authBox');
  await box.delete('currentUser');
}


  // get current user
  Future<AuthHiveModel?> getCurrentUser() async {
  final box = Hive.box<AuthHiveModel>('authBox');
  return box.get('currentUser'); // or however you store it
}

}