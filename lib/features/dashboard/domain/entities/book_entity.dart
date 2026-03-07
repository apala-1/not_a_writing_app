class BookAuthorEntity {
  final String id;
  final String? name;
  const BookAuthorEntity({required this.id, this.name});
}

class BookContentItemEntity {
  final String type; // "text" | "image"
  final String value;

  const BookContentItemEntity({required this.type, required this.value});
}

class BookChapterEntity {
  final String title;
  final List<BookContentItemEntity> content;

  const BookChapterEntity({required this.title, required this.content});
}

class BookEntity {
  final String id;
  final String title;
  final String description;

  final BookAuthorEntity? author;

  final String coverPhoto; // "image" | "file"
  final String coverPhotoUrl; // FULL URL usable in Image.network

  final int noOfChapters;
  final int noOfPages;

  final List<BookChapterEntity> chapters;

  final String status; // "draft" | "published"
  final String visibility; // "public" | "private" | "link"
  final String? shareToken;

  final DateTime? createdAt;

  const BookEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.coverPhoto,
    required this.coverPhotoUrl,
    required this.noOfChapters,
    required this.noOfPages,
    required this.chapters,
    required this.status,
    required this.visibility,
    required this.shareToken,
    required this.createdAt,
  });
}