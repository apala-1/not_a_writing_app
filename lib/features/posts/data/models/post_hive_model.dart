import 'package:hive/hive.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_attachment_hive_model.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_author_hive_model.dart';


part 'post_hive_model.g.dart';

@HiveType(typeId: 32)
class PostHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final PostAuthorHive? author;

  @HiveField(2)
  final String? title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? content;

  @HiveField(5)
  final List<PostAttachmentHive> attachments;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String visibility;

  @HiveField(8)
  final int viewsCount;

  @HiveField(9)
  final int likesCount;

  @HiveField(10)
  final int savesCount;

  @HiveField(11)
  final int sharesCount;

  @HiveField(12)
  final int commentsCount;

  @HiveField(13)
  final bool isLiked;

  @HiveField(14)
  final bool isSaved;

  /// store as millis for Hive simplicity
  @HiveField(15)
  final int? createdAtMillis;

  const PostHive({
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
    required this.createdAtMillis,
  });
}