import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:not_a_writing_app/features/posts/data/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/presentation/state/post_with_user_state.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>(
  (ref) => DashboardViewModel(ref),
);

class DashboardViewModel extends StateNotifier<DashboardState> {
  final Ref _ref;
  int _skip = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  DashboardViewModel(this._ref)
      : super(DashboardState(
          posts: const AsyncValue.loading(),
          profile: const AsyncValue.loading(),
        )) {
    fetchPosts();
    fetchProfileStats();
  }

  // ---------------- Posts ----------------
  Future<void> fetchPosts() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    try {
      final posts =
          await _ref.read(postRepositoryProvider).getAllPosts(skip: _skip, limit: _limit);

      if (posts.length < _limit) _hasMore = false;
      _skip += posts.length;

      final currentPosts = state.posts.value ?? [];
      final newPosts = posts.map((p) => PostWithUserState(post: p, isSaved: p.isSaved, isLiked: p.isLiked)).toList();

      state = state.copyWith(posts: AsyncValue.data([...currentPosts, ...newPosts]));
    } catch (e, st) {
      state = state.copyWith(posts: AsyncValue.error(e, st));
    } finally {
      _isLoading = false;
    }
  }

  bool get hasMore => _hasMore;

  Future<void> refreshPosts() async {
  _skip = 0;
  _hasMore = true;
  state = state.copyWith(posts: const AsyncValue.data([]));
  await fetchPosts();
}

  // ---------------- Profile ----------------
  Future<void> fetchProfileStats() async {
    state = state.copyWith(profile: const AsyncValue.loading());
    try {
      final user = _ref.read(authViewmodelProvider).authEntity;
      if (user == null) {
        state = state.copyWith(profile: AsyncValue.data(null));
        return;
      }

      final profile = await _ref.read(profileRemoteProvider).fetchProfileById(user.authId!);
      state = state.copyWith(profile: AsyncValue.data(profile));
    } catch (e, st) {
      state = state.copyWith(profile: AsyncValue.error(e, st));
    }
  }

  // ---------------- Post Actions ----------------
  Future<void> toggleLike(String postId) async {
  final updatedPost =
      await _ref.read(postRepositoryProvider).toggleLike(postId);

  _updatePostInState(
    postId,
    (p) => p.copyWith(
      post: updatedPost,
      isLiked: !p.isLiked, // or compute properly if needed
    ),
  );
}

 Future<void> toggleSave(String postId) async {
  final updatedPost =
      await _ref.read(postRepositoryProvider).toggleSave(postId);

  _updatePostInState(
    postId,
    (p) => p.copyWith(
      post: updatedPost,
      isSaved: !p.isSaved,
    ),
  );
}

  Future<void> addShare(String postId) async {
    await _ref.read(postRepositoryProvider).addShare(postId);

    _updatePostInState(postId, (p) => p.copyWith(
          post: p.post.copyWith(sharesCount: (p.post.sharesCount + 1)),
        ));
  }

  void _updatePostInState(
      String postId, PostWithUserState Function(PostWithUserState) updateFn) {
    final posts = state.posts.value;
    if (posts == null) return;

    state = state.copyWith(
      posts: AsyncValue.data(
        posts.map((p) => p.post.id == postId ? updateFn(p) : p).toList(),
      ),
    );
  }
}