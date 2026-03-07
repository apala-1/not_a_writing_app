import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';
import 'package:not_a_writing_app/features/posts/presentation/providers/posts_providers.dart';

final getPostsUsecaseProvider = Provider<GetAllPostsUsecase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return GetAllPostsUsecase(repository);
});

class GetAllPostsUsecase {
  final PostsRepository repo;
  GetAllPostsUsecase(this.repo);

  Future<List<PostEntity>> call({int skip = 0, int limit = 10}) {
    return repo.getAllPosts(skip: skip, limit: limit);
  }
}