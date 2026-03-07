import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/settings_remote_datasource.dart';

final settingsRemoteProvider = Provider((ref) {
  return SettingsRemoteDataSource(ref.read(apiClientProvider));
});