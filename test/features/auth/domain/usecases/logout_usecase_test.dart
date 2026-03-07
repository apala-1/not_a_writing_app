import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/usecases/logout_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late IAuthRepository repo;
  late LogoutUsecase usecase;

  setUp(() {
    repo = _MockAuthRepository();
    usecase = LogoutUsecase(authRepository: repo);
  });

  test('calls repo.logout and returns Right(true)', () async {
    when(() => repo.logout()).thenAnswer((_) async => const Right(true));

    final result = await usecase();

    expect(result, const Right<Failure, bool>(true));
    verify(() => repo.logout()).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('returns Left(Failure) when repo.logout fails', () async {
    final failure = ServerFailure(message: 'bad');

    when(() => repo.logout()).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left<Failure, bool>(failure));
    verify(() => repo.logout()).called(1);
    verifyNoMoreInteractions(repo);
  });
}