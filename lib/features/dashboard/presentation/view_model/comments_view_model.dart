import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/comments_state.dart';


class CommentsVm extends StateNotifier<CommentsState> {
  final CommentsRepository repo;
  final String postId;

  CommentsVm({required this.repo, required this.postId}) : super(CommentsState.initial());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    print('CommentsVm.load postId=$postId hash=${identityHashCode(this)}');
    try {
      final data = await repo.getByPost(postId);
      state = state.copyWith(loading: false, comments: data);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) return;
    await repo.create(postId: postId, content: content.trim());
    await load(); // simplest (you can optimize later)
  }

  Future<void> reply(String parentCommentId, String content) async {
    if (content.trim().isEmpty) return;
    await repo.reply(postId: postId, parentCommentId: parentCommentId, content: content.trim());
    await load();
  }

  Future<void> edit(String commentId, String content) async {
  if (content.trim().isEmpty) return;
  try {
    await repo.update(commentId: commentId, content: content.trim());
    await load();
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}

  Future<void> remove(String commentId) async {
    await repo.delete(commentId);
    await load();
  }
}