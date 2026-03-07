import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class ReplyToCommentUsecase {
  final CommentsRepository repo;
  ReplyToCommentUsecase(this.repo);

  Future<CommentEntity> call({
    required String postId,
    required String parentCommentId,
    required String content,
  }) {
    return repo.reply(postId: postId, parentCommentId: parentCommentId, content: content);
  }
}