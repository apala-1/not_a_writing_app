import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:not_a_writing_app/core/constants/hive_table_constant.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // ✅ Register adapters
  Hive.registerAdapter(AuthHiveModelAdapter());

  // ✅ Open your auth box once at startup
  await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

  // Shared Pref object
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
    child: MyApp()));
}
