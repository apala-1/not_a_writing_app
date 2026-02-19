import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
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

  const PostEntity({
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

  PostEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    bool? isDraft,
    List<Attachment>? attachments,
    int? viewsCount,
    int? likesCount,
    int? sharesCount,
    int? savesCount,
    int? commentsCount,
  }) {
    return PostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      isDraft: isDraft ?? this.isDraft,
      attachments: attachments ?? this.attachments,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savesCount: savesCount ?? this.savesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        isDraft,
        attachments,
        viewsCount,
        likesCount,
        sharesCount,
        savesCount,
        commentsCount
      ];
}

class Attachment {
  final String url;
  final String type; // image, gif, file

  Attachment({required this.url, required this.type});
}
