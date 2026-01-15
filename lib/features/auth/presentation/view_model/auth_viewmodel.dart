import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';

// provider
final authViewmodelProvider =
    NotifierProvider<AuthViewmodel, AuthState>(
      () => AuthViewmodel()
    );

class AuthViewmodel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({required String fullname, required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecaseParams(fullname: fullname, email: email, password: password);
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
              status: AuthStatus.error,
              errorMessage: "Registration failed. Please try again.");
        }
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
      },
      (authEntity) {
        state = state.copyWith(
            status: AuthStatus.authenticated, authEntity: authEntity);
      },
    );
  }

  Future<void> logout() async {
  state = state.copyWith(status: AuthStatus.loading);

  final result = await _logoutUsecase();

  result.fold(
    (failure) => state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: failure.message,
    ),
    (success) async {
      // Clear persisted session
      final userSessionService = ref.read(userSessionServiceProvider);
      await userSessionService.clearUserSession();

      // Update state
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        authEntity: null,
      );
    },
  );
}

}