import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared Prefs ko provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences instance not initialized');
});

// Provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys fo rstoring data
  static const String _keysIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullname = 'user_fullname'; 

  // Store user session data
  Future<void> saveUserSession({
  required String? authId,
  required String email,
  required String name,
}) async {
  await _prefs.setBool(_keysIsLoggedIn, true);
  await _prefs.setString(_keyUserId, authId!);
  await _prefs.setString(_keyUserEmail, email);
  await _prefs.setString(_keyUserFullname, name);
}



  // Clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keysIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullname);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keysIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUserFullname() {
    return _prefs.getString(_keyUserFullname);
  }
}
