import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_api_model.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/update_user_usecase.dart';


class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDatasource remote;

  ProfileRepository(this.remote);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profile = await remote.fetchProfile();
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
Future<Either<Failure, ProfileEntity>> getProfileById(String userId) async {
  try {
    final profile = await remote.fetchProfileById(userId);
    print('Raw profile fetched: ${profile.toJson()}');
    return Right(profile.toEntity());
  } catch (e) {
    return Left(ApiFailure(message: e.toString()));
  }
}
  
  @override
Future<Either<Failure, ProfileEntity>> updateUser(
  UpdateProfileParams params,
) async {
  try {
    final apiModel = await remote.updateProfile(params);
    return Right(apiModel.toEntity());
  } catch (e) {
    return Left(ApiFailure(message: e.toString()));
  }
}

@override
  Future<List<PostEntity>> getLikedPosts() async {
    final raw = await remote.getLikedPostsRaw();
    return raw.map((e) => PostApiModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
  }

  @override
  Future<List<PostEntity>> getSavedPosts() async {
    final raw = await remote.getSavedPostsRaw();
    return raw.map((e) => PostApiModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
  }
}