import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class GetCommentsByPostUsecase {
  final CommentsRepository repo;
  GetCommentsByPostUsecase(this.repo);

  Future<List<CommentEntity>> call(String postId) {
    return repo.getByPost(postId);
  }
}