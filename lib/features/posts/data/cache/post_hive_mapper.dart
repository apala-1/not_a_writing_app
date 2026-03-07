import 'package:not_a_writing_app/features/posts/data/models/post_attachment_hive_model.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_author_hive_model.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_hive_model.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';


PostHive postToHive(PostEntity p) {
  return PostHive(
    id: p.id,
    author: p.author == null
        ? null
        : PostAuthorHive(
            id: p.author!.id,
            name: p.author!.name,
            profilePictureUrl: p.author!.profilePictureUrl,
          ),
    title: p.title,
    description: p.description,
    content: p.content,
    attachments: p.attachments
        .map(
          (a) => PostAttachmentHive(
            id: a.id,
            url: a.url,
            type: a.type,
          ),
        )
        .toList(),
    status: p.status,
    visibility: p.visibility,
    viewsCount: p.viewsCount,
    likesCount: p.likesCount,
    savesCount: p.savesCount,
    sharesCount: p.sharesCount,
    commentsCount: p.commentsCount,
    isLiked: p.isLiked,
    isSaved: p.isSaved,
    createdAtMillis: p.createdAt?.millisecondsSinceEpoch,
  );
}

PostEntity postFromHive(PostHive h) {
  return PostEntity(
    id: h.id,
    author: h.author == null
        ? null
        : PostAuthorEntity(
            id: h.author!.id,
            name: h.author!.name,
            profilePictureUrl: h.author!.profilePictureUrl,
          ),
    title: h.title,
    description: h.description,
    content: h.content,
    attachments: h.attachments
        .map((a) => PostAttachmentEntity(id: a.id, url: a.url, type: a.type))
        .toList(),
    status: h.status,
    visibility: h.visibility,
    viewsCount: h.viewsCount,
    likesCount: h.likesCount,
    savesCount: h.savesCount,
    sharesCount: h.sharesCount,
    commentsCount: h.commentsCount,
    isLiked: h.isLiked,
    isSaved: h.isSaved,
    createdAt: h.createdAtMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(h.createdAtMillis!),
  );
}