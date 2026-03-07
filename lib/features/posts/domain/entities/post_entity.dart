class PostAuthorEntity {
  final String id;
  final String name;
  final String? profilePictureUrl;

  const PostAuthorEntity({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });
}

class PostAttachmentEntity {
  final String? id; // attachment _id from mongo (can be null for new uploads)
  final String url; // FULL URL for Image.network
  final String type; // "image" | "gif" | "file"

  const PostAttachmentEntity({
    required this.id,
    required this.url,
    required this.type,
  });
}

class PostEntity {
  final String id;
  final PostAuthorEntity? author;

  final String? title;
  final String? description;
  final String? content;

  final List<PostAttachmentEntity> attachments;

  final String status;     // draft/published
  final String visibility; // private/public

  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final int sharesCount;
  final int commentsCount;

  final bool isLiked;
  final bool isSaved;

  final DateTime? createdAt;

  const PostEntity({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.content,
    required this.attachments,
    required this.status,
    required this.visibility,
    required this.viewsCount,
    required this.likesCount,
    required this.savesCount,
    required this.sharesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });
}