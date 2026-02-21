import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';

class CommentApiModel extends CommentEntity {
  CommentApiModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.content,
    required super.createdAt,
  });

  factory CommentApiModel.fromJson(Map<String, dynamic> json) {
    return CommentApiModel(
      id: json['_id'],
      postId: json['post'],
      userId: json['user'] is Map
          ? json['user']['_id']
          : json['user'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
