import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';

enum CommentStatus { initial, loading, loaded, error }

class CommentState {
  final AsyncValue<List<CommentWithProfile>> comments;
  final CommentStatus status;
  final String? errorMessage;

  CommentState({
    required this.comments,
    this.status = CommentStatus.initial,
    this.errorMessage,
  });

  factory CommentState.initial() {
    return CommentState(comments: const AsyncValue.data([]));
  }

  CommentState copyWith({
    AsyncValue<List<CommentWithProfile>>? comments,
    CommentStatus? status,
    String? errorMessage,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
