import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';

final authViewmodelProvider =
    NotifierProvider<AuthViewmodel, AuthState>(() => AuthViewmodel());

class AuthViewmodel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
  _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
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
      (authEntity) async {
  // DEBUG: check what you got
  print('authId: "${authEntity.authId}", token: "${authEntity.token}"');

  final userSessionService = ref.read(userSessionServiceProvider);

  // check for empty strings too
  if (authEntity.authId == null || authEntity.authId!.isEmpty ||
      authEntity.token == null || authEntity.token!.isEmpty) {
    throw Exception('Login response missing required fields');
  }

  await userSessionService.saveUserSession(
    authId: authEntity.authId!,
    email: authEntity.email,
    name: authEntity.name,
    token: authEntity.token!,
  );

  print('Saved session: ${await userSessionService.getUserToken()}');

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
  Future<void> forgotPassword(String email) async {
  state = state.copyWith(status: AuthStatus.loading);

  final result = await _forgotPasswordUsecase(email);

  result.fold(
    (failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    },
    (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    },
  );
}

Future<void> resetPassword({
  required String token,
  required String password,
}) async {
  state = state.copyWith(status: AuthStatus.loading);

  final result = await _resetPasswordUsecase(
    ResetPasswordParams(
      token: token,
      password: password,
    ),
  );

  result.fold(
    (failure) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    },
    (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    },
  );
}

Future<void> loginWithGoogle(String idToken) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await ref.read(authRepositoryProvider).loginWithGoogle(idToken);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) async {
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.saveUserSession(
          authId: authEntity.authId!,
          email: authEntity.email,
          name: authEntity.name,
          token: authEntity.token!,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

}
