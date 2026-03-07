import '../entities/comment_entity.dart';

abstract class CommentsRepository {
  Future<List<CommentEntity>> getByPost(String postId);
  Future<CommentEntity> create({required String postId, required String content});
  Future<CommentEntity> reply({required String postId, required String parentCommentId, required String content});
  Future<CommentEntity> update({required String commentId, required String content});
  Future<void> delete(String commentId);
}