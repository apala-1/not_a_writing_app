import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';

final authViewmodelProvider =
    NotifierProvider<AuthViewmodel, AuthState>(() => AuthViewmodel());

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

  Future<void> register({
    String? authId,
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      authId: authId,
      name: name,
      email: email,
      password: password,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) async {
        // Save session
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.saveUserSession(
          authId: authEntity.authId,
          email: authEntity.email,
          name: authEntity.name,
        );

        state = state.copyWith(
          status: AuthStatus.registered,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) async {
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.clearUserSession();

        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
      },
    );
  }
}
