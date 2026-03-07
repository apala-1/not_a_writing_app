
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

class DeletePostUsecase {
  final PostsRepository repo;
  DeletePostUsecase(this.repo);

  Future<void> call(String postId) => repo.deletePost(postId);
}