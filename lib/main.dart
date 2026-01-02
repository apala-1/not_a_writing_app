import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:not_a_writing_app/core/constants/hive_table_constant.dart';
import 'package:not_a_writing_app/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // ✅ Register adapters
  Hive.registerAdapter(AuthHiveModelAdapter());

  // ✅ Open your auth box once at startup
  await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

  runApp(const ProviderScope(child: MyApp()));
}
