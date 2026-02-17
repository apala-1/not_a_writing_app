import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/usecases/app_usecases.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

final resetPasswordUsecaseProvider =
    Provider<ResetPasswordUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(repo);
});


class ResetPasswordParams extends Equatable {
  final String token;
  final String password;

  const ResetPasswordParams({
    required this.token,
    required this.password,
  });

  @override
  List<Object> get props => [token, password];
}

class ResetPasswordUsecase
    implements UsecaseWithParams<bool, ResetPasswordParams> {

  final IAuthRepository _repository;

  ResetPasswordUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      params.token,
      params.password,
    );
  }
}
