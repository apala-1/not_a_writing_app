import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class UpdateCommentUseCase {
  final CommentRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<CommentEntity> call(String commentId, String content) {
    return repository.updateComment(commentId, content);
  }
}
