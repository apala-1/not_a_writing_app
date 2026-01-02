import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/usecases/app_usecases.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullname;
  final String email;
  final String? password;

  const RegisterUsecaseParams({
    required this.fullname,
    required this.email,
    this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [fullname, email, password];
}

// Provider for RegisterUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams>{

  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
   final entity = AuthEntity(
      fullname: params.fullname,
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}