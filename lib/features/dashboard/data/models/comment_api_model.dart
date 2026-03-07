import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';

class CommentApiModel {
  final String id;
  final String postId;
  final CommentUserEntity user;
  final String content;
  final String? parentCommentId;
  final List<CommentApiModel> replies;
  final DateTime? createdAt;

  CommentApiModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.parentCommentId,
    required this.replies,
    required this.createdAt,
  });

  factory CommentApiModel.fromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user'] as Map);

    final rawReplies = (json['replies'] as List? ?? []);

final repliesJson = rawReplies
    .where((e) => e is Map) // ✅ ignore string ids
    .map((e) => CommentApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
    .toList();

    return CommentApiModel(
      id: (json['_id'] ?? json['id']).toString(),
      postId: (json['post'] is Map ? (json['post']['_id'] ?? json['post']).toString() : json['post'].toString()),
      user: CommentUserEntity(
        id: (userJson['_id'] ?? userJson['id']).toString(),
        name: (userJson['name'] ?? 'Unknown').toString(),
        profilePicture: userJson['profilePicture']?.toString(),
      ),
      content: (json['content'] ?? '').toString(),
      parentCommentId: json['parentComment']?.toString(),
      replies: repliesJson,
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  CommentEntity toEntity() => CommentEntity(
        id: id,
        postId: postId,
        user: user,
        content: content,
        parentCommentId: parentCommentId,
        replies: replies.map((r) => r.toEntity()).toList(),
        createdAt: createdAt,
      );
}