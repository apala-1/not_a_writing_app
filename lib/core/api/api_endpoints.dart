import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  // static const bool isPhysicalDevice = false;
  static const String _ipAddress = "10.231.98.66";
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

    // ===== AUTH (USER) =====
  static const String auth = '/auth';

  static const String register = '$auth/register';
  static const String login = '$auth/login';

  static const String me = '$auth/me';
  static const String updateMe = '$auth/me';
  static const String deleteMe = '$auth/me';

  // ===== ADMIN USERS =====
  static const String users = '/users';

  static String userById(String id) => '/users/$id';

  // ===== MEDIA =====
  static String media(String filename) => '$serverUrl/uploads/$filename';

  // ===== TIMEOUTS =====
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

}