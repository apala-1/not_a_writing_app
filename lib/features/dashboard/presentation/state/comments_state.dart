import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';

class CommentsState {
  final bool loading;
  final String? error;
  final List<CommentEntity> comments;

  const CommentsState({required this.loading, required this.comments, this.error});
  factory CommentsState.initial() => const CommentsState(loading: false, comments: []);
  CommentsState copyWith({bool? loading, String? error, List<CommentEntity>? comments}) {
    return CommentsState(
      loading: loading ?? this.loading,
      error: error,
      comments: comments ?? this.comments,
    );
  }
}
