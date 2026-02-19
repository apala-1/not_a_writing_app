import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/profile/data/repositories/profile_repository.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/repositories/profile_repository.dart';

final getProfileByIdUsecaseProvider = Provider<GetProfileByIdUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return GetProfileByIdUsecase(repository);
});

class GetProfileByIdUsecase {
  final IProfileRepository repository;

  GetProfileByIdUsecase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(String userId) {
    return repository.getProfileById(userId);
  }
}
