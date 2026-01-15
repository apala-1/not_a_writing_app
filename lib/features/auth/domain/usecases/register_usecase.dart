import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/usecases/app_usecases.dart';
import 'package:not_a_writing_app/features/auth/data/repositories/auth_repository.dart';
import 'package:not_a_writing_app/features/auth/domain/entities/auth_entity.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String? authId;
  final String name;
  final String email;
  final String? password;

  const RegisterUsecaseParams({
    this.authId,
    required this.name,
    required this.email,
    this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// Provider for RegisterUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<AuthEntity, RegisterUsecaseParams> {

      final IAuthRepository _authRepository;

      RegisterUsecase({
        required IAuthRepository authRepository,
      }) : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      authId: params.authId,
      name: params.name,
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
