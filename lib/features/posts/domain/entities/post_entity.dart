class Post {
  final String id;
  final String title;
  final String description;
  final String content;
  final bool isDraft;
  final List<Attachment> attachments;
  final int viewsCount;
  final int likesCount;
  final int sharesCount;
  final int savesCount;
  final int commentsCount;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.isDraft,
    this.attachments = const [],
    this.viewsCount = 0,
    this.likesCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.commentsCount = 0,
  });
}

class Attachment {
  final String url;
  final String type; // image, gif, file

  Attachment({required this.url, required this.type});
}
