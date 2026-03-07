import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/liked_saved_posts_state.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_liked_posts_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_saved_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_save_usecase.dart';

class LikedSavedPostsViewModel extends StateNotifier<LikedSavedPostsState> {
  final GetLikedPostsUsecase getLiked;
  final GetSavedPostsUsecase getSaved;
  final ToggleLikeUsecase toggleLike;
  final ToggleSaveUsecase toggleSave;

  LikedSavedPostsViewModel({
    required this.getLiked,
    required this.getSaved,
    required this.toggleLike,
    required this.toggleSave,
  }) : super(const LikedSavedPostsState());

  Future<void> load({LikedSavedTab? tab}) async {
    final nextTab = tab ?? state.tab;
    state = state.copyWith(tab: nextTab, loading: true, error: null);

    try {
      final posts = nextTab == LikedSavedTab.liked ? await getLiked() : await getSaved();
      state = state.copyWith(loading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> toggleLikeFromHere(String postId) async {
    state = state.copyWith(error: null);
    try {
      final updated = await toggleLike(postId);

      // If on liked tab and now unliked -> remove from list
      if (state.tab == LikedSavedTab.liked && updated.isLiked == false) {
        state = state.copyWith(posts: state.posts.where((p) => p.id != postId).toList());
        return;
      }

      // Otherwise update in-place
      state = state.copyWith(
        posts: state.posts.map((p) => p.id == postId ? updated : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleSaveFromHere(String postId) async {
    state = state.copyWith(error: null);
    try {
      final updated = await toggleSave(postId);

      // If on saved tab and now unsaved -> remove from list
      if (state.tab == LikedSavedTab.saved && updated.isSaved == false) {
        state = state.copyWith(posts: state.posts.where((p) => p.id != postId).toList());
        return;
      }

      state = state.copyWith(
        posts: state.posts.map((p) => p.id == postId ? updated : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}