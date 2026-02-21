import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase(this.repository);

  Future<CommentEntity> call(String postId, String content) {
    return repository.createComment(postId, content);
  }
}
