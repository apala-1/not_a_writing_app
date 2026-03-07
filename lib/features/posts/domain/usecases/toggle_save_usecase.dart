import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

import '../entities/post_entity.dart';

class ToggleSaveUsecase {
  final PostsRepository repo;
  ToggleSaveUsecase(this.repo);

  Future<PostEntity> call(String postId) => repo.toggleSave(postId);
}