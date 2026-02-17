import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/usecases/app_usecases.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

final forgotPasswordUsecaseProvider =
    Provider<ForgotPasswordUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(repo);
});


class ForgotPasswordUsecase
    implements UsecaseWithParams<bool, String> {

  final IAuthRepository _repository;

  ForgotPasswordUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(String email) {
    return _repository.forgotPassword(email);
  }
}
