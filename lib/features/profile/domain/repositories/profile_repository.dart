import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/repositories/profile_repository.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final remote = ref.read(profileRemoteProvider);
  return ProfileRepository(remote);
});

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
    Future<Either<Failure, ProfileEntity>> getProfileById(String userId);
  Future<Either<Failure, ProfileEntity>> updateUser(UpdateProfileParams params);
  Future<List<PostEntity>> getLikedPosts();
  Future<List<PostEntity>> getSavedPosts();
}