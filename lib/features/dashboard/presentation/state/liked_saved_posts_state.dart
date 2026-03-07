import 'package:equatable/equatable.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

enum LikedSavedTab { liked, saved }

class LikedSavedPostsState extends Equatable {
  final LikedSavedTab tab;
  final bool loading;
  final String? error;
  final List<PostEntity> posts;

  const LikedSavedPostsState({
    this.tab = LikedSavedTab.liked,
    this.loading = false,
    this.error,
    this.posts = const [],
  });

  LikedSavedPostsState copyWith({
    LikedSavedTab? tab,
    bool? loading,
    String? error,
    List<PostEntity>? posts,
  }) {
    return LikedSavedPostsState(
      tab: tab ?? this.tab,
      loading: loading ?? this.loading,
      error: error,
      posts: posts ?? this.posts,
    );
  }

  @override
  List<Object?> get props => [tab, loading, error, posts];
}