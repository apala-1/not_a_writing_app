import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/core/usecases/app_usecases.dart';
import 'package:not_a_writing_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecaseParams extends Equatable {
  const GetCurrentUserUsecaseParams();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetCurrentUserUsecase implements UsecaseWithoutParams{
  @override
  Future<Either<Failure, dynamic>> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}