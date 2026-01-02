import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../state/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  Future<void> login(String email, String password) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      final user = await loginUseCase(email, password);
      _state = AuthAuthenticated(
        userId: user.id,
        email: user.email,
      );
    } catch (e) {
      _state = AuthError("Login failed");
    }

    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      final user = await registerUseCase(name, email, password);
      _state = AuthAuthenticated(
        userId: user.id,
        email: user.email,
      );
    } catch (e) {
      _state = AuthError("Registration failed");
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await logoutUseCase();
    _state = AuthUnauthenticated();
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final user = await getCurrentUserUseCase();
    if (user != null) {
      _state = AuthAuthenticated(
        userId: user.id,
        email: user.email,
      );
    } else {
      _state = AuthUnauthenticated();
    }
    notifyListeners();
  }
}
