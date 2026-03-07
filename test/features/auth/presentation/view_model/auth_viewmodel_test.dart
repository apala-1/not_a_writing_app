import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:not_a_writing_app/features/auth/presentation/state/auth_state.dart';

class _MockRegisterUsecase extends Mock implements RegisterUsecase {}

class _MockLoginUsecase extends Mock implements LoginUsecase {}

class _MockLogoutUsecase extends Mock implements LogoutUsecase {}

class _MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class _MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class _MockUserSessionService extends Mock implements UserSessionService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    // Needed if you use any() with these types anywhere.
    registerFallbackValue(const RegisterUsecaseParams(
      authId: 'x',
      name: 'x',
      email: 'x@x.com',
      password: 'x',
    ));
    registerFallbackValue(const LoginUsecaseParams(email: 'x@x.com', password: 'x'));
    registerFallbackValue(const ResetPasswordParams(token: 't', password: 'p'));

    registerFallbackValue(const AuthEntity(
      authId: 'x',
      name: 'x',
      email: 'x@x.com',
      token: 't',
    ));
  });

  late RegisterUsecase registerUsecase;
  late LoginUsecase loginUsecase;
  late LogoutUsecase logoutUsecase;
  late ForgotPasswordUsecase forgotPasswordUsecase;
  late ResetPasswordUsecase resetPasswordUsecase;
  late UserSessionService userSessionService;
  late AuthRepository authRepository;

  ProviderContainer _container() {
    return ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(registerUsecase),
        loginUsecaseProvider.overrideWithValue(loginUsecase),
        logoutUsecaseProvider.overrideWithValue(logoutUsecase),
        forgotPasswordUsecaseProvider.overrideWithValue(forgotPasswordUsecase),
        resetPasswordUsecaseProvider.overrideWithValue(resetPasswordUsecase),
        userSessionServiceProvider.overrideWithValue(userSessionService),

        // for loginWithGoogle()
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  }

  setUp(() {
    registerUsecase = _MockRegisterUsecase();
    loginUsecase = _MockLoginUsecase();
    logoutUsecase = _MockLogoutUsecase();
    forgotPasswordUsecase = _MockForgotPasswordUsecase();
    resetPasswordUsecase = _MockResetPasswordUsecase();
    userSessionService = _MockUserSessionService();
    authRepository = _MockAuthRepository();

    // Default stubs to avoid "MissingStubError" if accidentally called
    when(() => userSessionService.saveUserSession(
          authId: any(named: 'authId'),
          email: any(named: 'email'),
          name: any(named: 'name'),
          token: any(named: 'token'),
        )).thenAnswer((_) async {});
    when(() => userSessionService.clearUserSession()).thenAnswer((_) async {});
    when(() => userSessionService.getUserToken()).thenReturn(null);
  });

  tearDown(() {
    // containers created per-test; nothing global to dispose here
  });

  test('build(): returns initial AuthState', () {
    final container = _container();
    addTearDown(container.dispose);

    final state = container.read(authViewmodelProvider);

    expect(state, const AuthState());
  });

  test('register(): sets loading then registered on success', () async {
    final container = _container();
    addTearDown(container.dispose);

    const auth = AuthEntity(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      token: 't',
    );

    when(() => registerUsecase(any())).thenAnswer((_) async => const Right(auth));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.register(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      password: 'pw',
    );

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.registered);
    expect(state.authEntity, auth);

    verify(() => registerUsecase(const RegisterUsecaseParams(
          authId: '1',
          name: 'Test',
          email: 'a@b.com',
          password: 'pw',
        ))).called(1);
  });

  test('register(): sets error on failure', () async {
    final container = _container();
    addTearDown(container.dispose);

    final failure = ApiFailure(statusCode: 400, message: 'bad');

    when(() => registerUsecase(any())).thenAnswer((_) async => Left(failure));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.register(
      name: 'Test',
      email: 'a@b.com',
      password: 'pw',
    );

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'bad');
  });


  test('login(): sets error on failure', () async {
    final container = _container();
    addTearDown(container.dispose);

    final failure = ApiFailure(statusCode: 401, message: 'unauthorized');

    when(() => loginUsecase(any())).thenAnswer((_) async => Left(failure));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.login(email: 'a@b.com', password: 'pw');

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'unauthorized');

    verifyNever(() => userSessionService.saveUserSession(
          authId: any(named: 'authId'),
          email: any(named: 'email'),
          name: any(named: 'name'),
          token: any(named: 'token'),
        ));
  });

  test('logout(): sets error on failure', () async {
    final container = _container();
    addTearDown(container.dispose);

    final failure = ApiFailure(statusCode: 500, message: 'oops');

    when(() => logoutUsecase()).thenAnswer((_) async => Left(failure));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.logout();

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'oops');

    verifyNever(() => userSessionService.clearUserSession());
  });

  test('forgotPassword(): sets unauthenticated on success', () async {
    final container = _container();
    addTearDown(container.dispose);

    when(() => forgotPasswordUsecase('a@b.com')).thenAnswer((_) async => const Right(true));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.forgotPassword('a@b.com');

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.unauthenticated);

    verify(() => forgotPasswordUsecase('a@b.com')).called(1);
  });

  test('forgotPassword(): sets error on failure', () async {
    final container = _container();
    addTearDown(container.dispose);

    final failure = ApiFailure(statusCode: 400, message: 'bad');

    when(() => forgotPasswordUsecase('a@b.com')).thenAnswer((_) async => Left(failure));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.forgotPassword('a@b.com');

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'bad');
  });

  test('resetPassword(): sets unauthenticated on success', () async {
    final container = _container();
    addTearDown(container.dispose);

    when(() => resetPasswordUsecase(any())).thenAnswer((_) async => const Right(true));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.resetPassword(token: 't', password: 'p');

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.unauthenticated);

    verify(() => resetPasswordUsecase(const ResetPasswordParams(token: 't', password: 'p'))).called(1);
  });

  test('resetPassword(): sets error on failure', () async {
    final container = _container();
    addTearDown(container.dispose);

    final failure = ApiFailure(statusCode: 400, message: 'bad');

    when(() => resetPasswordUsecase(any())).thenAnswer((_) async => Left(failure));

    final notifier = container.read(authViewmodelProvider.notifier);

    await notifier.resetPassword(token: 't', password: 'p');

    final state = container.read(authViewmodelProvider);

    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'bad');
  });
}