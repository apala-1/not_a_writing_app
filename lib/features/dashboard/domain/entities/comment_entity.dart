import 'comment_user_entity.dart';

class CommentEntity {
  final String id;
  final String postId;
  final CommentUserEntity user;
  final String content;
  final String? parentCommentId;
  final List<CommentEntity> replies;
  final DateTime? createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.parentCommentId,
    required this.replies,
    required this.createdAt,
  });

  bool get isReply => parentCommentId != null;
}