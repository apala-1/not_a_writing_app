import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  // static const bool isPhysicalDevice = false;
  static const String _ipAddress = "10.63.123.66";
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (Platform.isAndroid) {
      return _ipAddress;
    }
    if (kIsWeb || Platform.isIOS) return 'localhost';
    // if(Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1';
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ user Endpoints ============
  static const String users = '/users';
  static const String userLogin = '/users/login';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => '/users/$id/photo';
  static const String userMe = '/users/me';

}