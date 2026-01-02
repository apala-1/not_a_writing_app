import 'package:dartz/dartz.dart';
import 'package:not_a_writing_app/core/error/failures.dart';

abstract interface class UsecaseWithParams<SuccessType,Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}