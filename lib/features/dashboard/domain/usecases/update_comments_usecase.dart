import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class UpdateCommentUsecase {
  final CommentsRepository repo;
  UpdateCommentUsecase(this.repo);

  Future<CommentEntity> call({required String commentId, required String content}) {
    return repo.update(commentId: commentId, content: content);
  }
}