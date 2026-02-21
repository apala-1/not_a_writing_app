import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  Future<List<CommentEntity>> getComments(String postId);
  Future<CommentEntity> createComment(String postId, String content);
  Future<CommentEntity> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}
