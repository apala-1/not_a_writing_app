import 'package:equatable/equatable.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/attachment_entity.dart';

class PostEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;

  final String authorId;
  final String authorName;
  final String authorProfilePicture;

  final String status;      // "draft" | "published"
  final String visibility;  // "public" | "private"

  final List<Attachment> attachments;

  final int viewsCount;
  final int likesCount;
  final int sharesCount;
  final int savesCount;
  final int commentsCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,

    required this.authorId,
    required this.authorName,
    required this.authorProfilePicture,

    required this.status,
    required this.visibility,

    this.attachments = const [],

    this.viewsCount = 0,
    this.likesCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.commentsCount = 0,

    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDraft => status == "draft";

  PostEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? authorId,
    String? authorName,
    String? authorProfilePicture,
    String? status,
    String? visibility,
    List<Attachment>? attachments,
    int? viewsCount,
    int? likesCount,
    int? sharesCount,
    int? savesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfilePicture:
          authorProfilePicture ?? this.authorProfilePicture,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      attachments: attachments ?? this.attachments,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savesCount: savesCount ?? this.savesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        authorId,
        authorName,
        authorProfilePicture,
        status,
        visibility,
        attachments,
        viewsCount,
        likesCount,
        sharesCount,
        savesCount,
        commentsCount,
        createdAt,
        updatedAt,
      ];
}