import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostAuthorApiModel {
  final String id;
  final String name;
  final String? profilePicture; // filename like "1772-xxx.jpg"

  PostAuthorApiModel({
    required this.id,
    required this.name,
    required this.profilePicture,
  });

  factory PostAuthorApiModel.fromJson(Map<String, dynamic> json) {
    return PostAuthorApiModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '').toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  PostAuthorEntity toEntity() {
    final pfp = profilePicture;
    return PostAuthorEntity(
      id: id,
      name: name,
      profilePictureUrl: (pfp == null || pfp.isEmpty)
          ? null
          : ApiEndpoints.profileImageUrl(pfp),
    );
  }
}

class PostAttachmentApiModel {
  final String? id; // mongo _id
  final String url; // can be "/uploads/posts/xxx.jpg" OR full url
  final String type;

  PostAttachmentApiModel({
    required this.id,
    required this.url,
    required this.type,
  });

  factory PostAttachmentApiModel.fromJson(Map<String, dynamic> json) {
    return PostAttachmentApiModel(
      id: json['_id']?.toString(),
      url: (json['url'] ?? '').toString(),
      type: (json['type'] ?? 'image').toString(),
    );
  }

  PostAttachmentEntity toEntity() {
    final raw = url.trim();
    final fullUrl = (raw.startsWith('http://') || raw.startsWith('https://'))
        ? raw
        : '${ApiEndpoints.serverUrl}$raw'; // because backend gives "/uploads/posts/.."
    return PostAttachmentEntity(
      id: id,
      url: fullUrl,
      type: type,
    );
  }
}

class PostApiModel {
  final String id;
  final PostAuthorApiModel? author;

  final String? title;
  final String? description;
  final String? content;

  final List<PostAttachmentApiModel> attachments;

  final String status;
  final String visibility;

  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final int sharesCount;
  final int commentsCount;

  final bool isLiked;
  final bool isSaved;

  final DateTime? createdAt;

  PostApiModel({
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

  factory PostApiModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    bool asBool(dynamic v) => (v is bool) ? v : (v?.toString() == 'true');

    final rawAuthor = json['author'];
    final author = (rawAuthor is Map<String, dynamic>) ? PostAuthorApiModel.fromJson(rawAuthor) : null;

    final rawAtt = json['attachments'];
    final attachments = (rawAtt is List)
        ? rawAtt
            .whereType<Map>()
            .map((e) => PostAttachmentApiModel.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <PostAttachmentApiModel>[];

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt == null ? null : DateTime.tryParse(rawCreatedAt.toString());

    return PostApiModel(
      id: (json['_id'] ?? json['id']).toString(),
      author: author,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      content: json['content']?.toString(),
      attachments: attachments,
      status: (json['status'] ?? 'published').toString(),
      visibility: (json['visibility'] ?? 'public').toString(),
      viewsCount: asInt(json['viewsCount']),
      likesCount: asInt(json['likesCount']),
      savesCount: asInt(json['savesCount']),
      sharesCount: asInt(json['sharesCount']),
      commentsCount: asInt(json['commentsCount']),
      isLiked: asBool(json['isLiked']),
      isSaved: asBool(json['isSaved']),
      createdAt: createdAt,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      author: author?.toEntity(),
      title: title,
      description: description,
      content: content,
      attachments: attachments.map((a) => a.toEntity()).toList(),
      status: status,
      visibility: visibility,
      viewsCount: viewsCount,
      likesCount: likesCount,
      savesCount: savesCount,
      sharesCount: sharesCount,
      commentsCount: commentsCount,
      isLiked: isLiked,
      isSaved: isSaved,
      createdAt: createdAt,
    );
  }
}