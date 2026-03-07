
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class DeleteCommentUsecase {
  final CommentsRepository repo;
  DeleteCommentUsecase(this.repo);

  Future<void> call(String commentId) {
    return repo.delete(commentId);
  }
}