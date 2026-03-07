import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/login_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late IAuthRepository repo;
  late LoginUsecase usecase;

  setUp(() {
    repo = _MockAuthRepository();
    usecase = LoginUsecase(authRepository: repo);
  });

  test('calls repo.login(email, password) and returns Right(AuthEntity)', () async {
    const auth = AuthEntity(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      token: 'token',
    );

    when(() => repo.login(any(), any())).thenAnswer((_) async => const Right(auth));

    final result = await usecase(const LoginUsecaseParams(
      email: 'a@b.com',
      password: 'pw',
    ));

    expect(result, const Right<Failure, AuthEntity>(auth));
    verify(() => repo.login('a@b.com', 'pw')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('uses empty password when params.password is null', () async {
    const auth = AuthEntity(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      token: 'token',
    );

    when(() => repo.login(any(), any())).thenAnswer((_) async => const Right(auth));

    final result = await usecase(const LoginUsecaseParams(
      email: 'a@b.com',
      password: null,
    ));

    expect(result, const Right<Failure, AuthEntity>(auth));
    verify(() => repo.login('a@b.com', '')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('returns Left(Failure) when repo.login fails', () async {
    final failure = ServerFailure(message: 'bad');

    when(() => repo.login(any(), any())).thenAnswer((_) async => Left(failure));

    final result = await usecase(const LoginUsecaseParams(
      email: 'a@b.com',
      password: 'pw',
    ));

    expect(result, Left<Failure, AuthEntity>(failure));
    verify(() => repo.login('a@b.com', 'pw')).called(1);
    verifyNoMoreInteractions(repo);
  });
}