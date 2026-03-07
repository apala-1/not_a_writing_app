import 'package:hive/hive.dart';

part 'post_attachment_hive_model.g.dart';

@HiveType(typeId: 31)
class PostAttachmentHive {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String type;

  const PostAttachmentHive({
    required this.id,
    required this.url,
    required this.type,
  });
}