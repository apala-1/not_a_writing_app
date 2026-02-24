import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostWithUserState {
  final PostEntity post;
  final bool isSaved;
  final bool isLiked;

  PostWithUserState({required this.post, required this.isSaved, required this.isLiked});

  PostWithUserState copyWith({PostEntity? post, bool? isSaved, bool? isLiked}) {
    return PostWithUserState(
      post: post ?? this.post,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}