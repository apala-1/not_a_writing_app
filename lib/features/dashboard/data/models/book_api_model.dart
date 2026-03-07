import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';

class BookApiModel {
  final String id;
  final String title;
  final String description;

  final Map<String, dynamic>? author; // populated object or id
  final String coverPhoto;
  final String coverPhotoUrl;

  final int noOfChapters;
  final int noOfPages;

  final List<dynamic> chapters;

  final String status;
  final String visibility;
  final String? shareToken;

  final DateTime? createdAt;

  BookApiModel({
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

  factory BookApiModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt == null ? null : DateTime.tryParse(rawCreatedAt.toString());

    return BookApiModel(
      id: (json['_id'] ?? json['id']).toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      author: (json['author'] is Map<String, dynamic>)
          ? (json['author'] as Map<String, dynamic>)
          : (json['author'] != null ? {'_id': json['author'].toString()} : null),
      coverPhoto: (json['coverPhoto'] ?? 'image').toString(),
      coverPhotoUrl: (json['coverPhotoUrl'] ?? '').toString(),
      noOfChapters: asInt(json['noOfChapters']),
      noOfPages: asInt(json['noOfPages']),
      chapters: (json['chapters'] is List) ? (json['chapters'] as List) : const [],
      status: (json['status'] ?? 'published').toString(),
      visibility: (json['visibility'] ?? 'private').toString(),
      shareToken: json['shareToken']?.toString(),
      createdAt: createdAt,
    );
  }

  BookEntity toEntity() {
    final rawUrl = coverPhotoUrl.trim();
    final fullCoverUrl = rawUrl.startsWith('http')
        ? rawUrl
        : '${ApiEndpoints.serverUrl}$rawUrl'; // e.g. "/uploads/books/.."

    BookAuthorEntity? authorEntity;
    if (author != null) {
      authorEntity = BookAuthorEntity(
        id: (author!['_id'] ?? '').toString(),
        name: author!['name']?.toString(),
      );
    }

    final chapterEntities = chapters.map((c) {
      final map = (c as Map).cast<String, dynamic>();
      final title = (map['title'] ?? 'Untitled Chapter').toString();
      final content = (map['content'] is List ? map['content'] as List : const [])
          .map((item) {
            final m = (item as Map).cast<String, dynamic>();
            return BookContentItemEntity(
              type: (m['type'] ?? 'text').toString(),
              value: (m['value'] ?? '').toString(),
            );
          })
          .toList();

      return BookChapterEntity(title: title, content: content);
    }).toList();

    return BookEntity(
      id: id,
      title: title,
      description: description,
      author: authorEntity,
      coverPhoto: coverPhoto,
      coverPhotoUrl: fullCoverUrl,
      noOfChapters: noOfChapters,
      noOfPages: noOfPages,
      chapters: chapterEntities,
      status: status,
      visibility: visibility,
      shareToken: shareToken,
      createdAt: createdAt,
    );
  }
}