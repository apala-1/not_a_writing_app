import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';
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

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
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
}