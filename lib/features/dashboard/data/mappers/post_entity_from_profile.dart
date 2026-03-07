import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

PostEntity postEntityFromProfilePostsJson(
  Map<String, dynamic> json, {
  required String currentUserId,
}) {
  final attachmentsJson = (json['attachments'] as List?) ?? const [];

  final likes = (json['likes'] as List?) ?? const [];
  final savedBy = (json['savedBy'] as List?) ?? const [];

  final isLiked = likes.any((id) => id.toString() == currentUserId);
  final isSaved = savedBy.any((id) => id.toString() == currentUserId);

  return PostEntity(
    id: (json['_id'] ?? '').toString(),
    author: null, // cannot build name/pfp yet because backend gives only id
    title: json['title']?.toString(),
    description: json['description']?.toString(),
    content: json['content']?.toString(),
    attachments: attachmentsJson.map((a) {
      final m = a as Map<String, dynamic>;
      final rawUrl = (m['url'] ?? '').toString(); // "/uploads/posts/..jpg"

      // build full URL
      final fullUrl = rawUrl.startsWith('http')
          ? rawUrl
          : '${ApiEndpoints.mediaServerUrl}$rawUrl';

      return PostAttachmentEntity(
        id: m['_id']?.toString(),
        url: fullUrl,
        type: (m['type'] ?? 'image').toString(),
      );
    }).toList(),
    status: (json['status'] ?? 'published').toString(),
    visibility: (json['visibility'] ?? 'public').toString(),
    viewsCount: (json['viewsCount'] ?? 0) as int,
    likesCount: (json['likesCount'] ?? 0) as int,
    savesCount: (json['savesCount'] ?? 0) as int,
    sharesCount: (json['sharesCount'] ?? 0) as int,
    commentsCount: (json['commentsCount'] ?? 0) as int,
    isLiked: isLiked,
    isSaved: isSaved,
    createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
  );
}