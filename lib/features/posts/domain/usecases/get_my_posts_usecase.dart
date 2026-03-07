import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';


class GetMyPostsUsecase {
  final PostsRepository repo;
  GetMyPostsUsecase(this.repo);

  Future<List<PostEntity>> call() {
    return repo.getMyPosts();
  }
}