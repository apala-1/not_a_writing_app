import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';

final getPostsUsecaseProvider = Provider<GetPostsUsecase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return GetPostsUsecase(repository);
});

class GetPostsUsecase {
  final IPostRepository repository;

  GetPostsUsecase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call({int skip = 0, int limit = 10}) async {
    try {
      final posts = await repository.getAllPosts(skip: skip, limit: limit);
      return Right(posts);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}