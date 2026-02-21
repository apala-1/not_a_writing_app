import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
