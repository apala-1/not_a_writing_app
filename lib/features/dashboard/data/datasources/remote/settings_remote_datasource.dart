import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';

class SettingsRemoteDataSource {
  final ApiClient api;
  SettingsRemoteDataSource(this.api);

  Future<Map<String, dynamic>> updateMe({String? email, String? password}) async {
    final form = FormData.fromMap({
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    });

    final res = await api.dio.put(ApiEndpoints.me, data: form);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> deleteMe() async {
    await api.dio.delete(ApiEndpoints.me);
  }
}