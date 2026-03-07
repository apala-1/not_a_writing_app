import 'package:hive/hive.dart';

part 'post_author_hive_model.g.dart';

@HiveType(typeId: 30)
class PostAuthorHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? profilePictureUrl;

  const PostAuthorHive({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });
}