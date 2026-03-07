
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class DashboardState {
  final bool loading;
  final bool loadingMore;
  final String? error;
  final List<PostEntity> posts;
  final bool hasMore;

  const DashboardState({
    required this.loading,
    required this.loadingMore,
    required this.posts,
    required this.hasMore,
    this.error,
  });

  factory DashboardState.initial() => const DashboardState(
        loading: false,
        loadingMore: false,
        posts: [],
        hasMore: true,
      );

  DashboardState copyWith({
    bool? loading,
    bool? loadingMore,
    String? error,
    List<PostEntity>? posts,
    bool? hasMore,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}