import 'package:not_a_writing_app/features/posts/domain/entities/attachment_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostApiModel {
  final String id;
  final String title;
  final String content;
  final String description;

  final String authorId;
  final String authorName;
  final String authorProfilePicture;

  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final int viewsCount;

  final String status;
  final String visibility;

  final List<Attachment> attachments;

  final DateTime createdAt;
  final DateTime updatedAt;

  PostApiModel({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.authorProfilePicture,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.savesCount,
    required this.viewsCount,
    required this.status,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt, required this.attachments,
  });

  factory PostApiModel.fromJson(Map<String, dynamic> json) {
  final authorData = json['author'];
  final authorId = authorData is Map ? authorData['_id'] ?? '' : authorData.toString();
  final authorName = authorData is Map ? authorData['name'] ?? '' : 'Unknown';
  final authorProfilePicture =
      authorData is Map ? authorData['profilePicture'] ?? 'default-picture.png' : 'default-picture.png';

  return PostApiModel(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    description: json['description'] ?? '',
    authorId: authorId,
    authorName: authorName,
    authorProfilePicture: authorProfilePicture,
    likesCount: json['likesCount'] ?? 0,
    commentsCount: json['commentsCount'] ?? 0,
    sharesCount: json['sharesCount'] ?? 0,
    savesCount: json['savesCount'] ?? 0,
    viewsCount: json['viewsCount'] ?? 0,
    status: json['status'] ?? 'draft',
    visibility: json['visibility'] ?? 'public',
    attachments: (json['attachments'] as List? ?? []).map((a) {
      if (a is Map<String, dynamic>) {
        return Attachment(
          url: a['url'] ?? '',
          type: a['type'] ?? 'file',
        );
      } else if (a is String) {
        return Attachment(url: a, type: 'file');
      } else {
        return Attachment(url: '', type: 'file');
      }
    }).toList(),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "description": description,
      "status": status,
      "visibility": visibility,
      "attachments": attachments
          .map((a) => {
                "url": a.url,
                "type": a.type,
              })
          .toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      title: title,
      content: content,
      description: description,
      authorId: authorId,
      authorName: authorName,
      authorProfilePicture: authorProfilePicture,
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      savesCount: savesCount,
      viewsCount: viewsCount,
      status: status,
      visibility: visibility,
      attachments: attachments,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PostApiModel.fromEntity(PostEntity entity) {
    return PostApiModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      description: entity.description,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorProfilePicture: entity.authorProfilePicture,
      likesCount: entity.likesCount,
      commentsCount: entity.commentsCount,
      sharesCount: entity.sharesCount,
      savesCount: entity.savesCount,
      viewsCount: entity.viewsCount,
      status: entity.status,
      visibility: entity.visibility,
      attachments: entity.attachments,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}