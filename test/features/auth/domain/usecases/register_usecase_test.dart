import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/register_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthEntity(
      authId: 'fallback',
      name: 'Fallback',
      email: 'fallback@example.com',
      password: 'pw',
      token: null,
    ));
  });

  late IAuthRepository repo;
  late RegisterUsecase usecase;

  setUp(() {
    repo = _MockAuthRepository();
    usecase = RegisterUsecase(authRepository: repo);
  });

  test('creates AuthEntity from params and calls repo.register(entity)', () async {
    const auth = AuthEntity(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      password: 'pw',
      token: 'token',
    );

    when(() => repo.register(any())).thenAnswer((_) async => const Right(auth));

    final result = await usecase(const RegisterUsecaseParams(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      password: 'pw',
    ));

    expect(result, const Right<Failure, AuthEntity>(auth));

    verify(() => repo.register(const AuthEntity(
          authId: '1',
          name: 'Test',
          email: 'a@b.com',
          password: 'pw',
        ))).called(1);

    verifyNoMoreInteractions(repo);
  });

  test('returns Left(Failure) when repo.register fails', () async {
    final failure = ApiFailure(statusCode: 400, message: 'bad');

    when(() => repo.register(any())).thenAnswer((_) async => Left(failure));

    final result = await usecase(const RegisterUsecaseParams(
      authId: '1',
      name: 'Test',
      email: 'a@b.com',
      password: 'pw',
    ));

    expect(result, Left<Failure, AuthEntity>(failure));
    verify(() => repo.register(any())).called(1);
    verifyNoMoreInteractions(repo);
  });
}