import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:not_a_writing_app/features/posts/data/cache/dashboard_feed_cache.dart';
import 'package:not_a_writing_app/features/posts/data/cache/post_hive_mapper.dart'; // <-- ADD THIS (your mapper file)
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_save_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/update_post_usecase.dart';

class DashboardViewModel extends StateNotifier<DashboardState> {
  final GetAllPostsUsecase getAllPosts;
  final CreatePostUsecase createPost;
  final UpdatePostUsecase updatePost;
  final DeletePostUsecase deletePost;
  final ToggleLikeUsecase toggleLike;
  final ToggleSaveUsecase toggleSave;

  final DashboardFeedCache cache;

  static const int _limit = 10;
  int _skip = 0;

  DashboardViewModel({
    required this.getAllPosts,
    required this.createPost,
    required this.updatePost,
    required this.deletePost,
    required this.toggleLike,
    required this.toggleSave,
    required this.cache,
  }) : super(DashboardState.initial());

  Future<void> _writeCacheFromState() async {
    await cache.writePosts(state.posts.map(postToHive).toList());
  }

  Future<void> _loadCacheIntoStateIfAny() async {
    final cached = await cache.readPosts();
    if (cached.isNotEmpty) {
      state = state.copyWith(posts: cached.map(postFromHive).toList());
      _skip = state.posts.length;
    }
  }

  Future<void> refresh() async {
    // 1) show cache ASAP
    state = state.copyWith(loading: true, error: null);
    await _loadCacheIntoStateIfAny();

    // 2) then try network
    _skip = 0;
    try {
      final data = await getAllPosts(skip: 0, limit: _limit);
      _skip = data.length;

      state = state.copyWith(
        loading: false,
        posts: data,
        hasMore: data.length == _limit,
      );

      await _writeCacheFromState();
    } catch (e) {
      // keep whatever is in state.posts (likely cache)
      state = state.copyWith(
        loading: false,
        error: state.posts.isNotEmpty ? 'Offline. Showing cached posts.' : e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;

    state = state.copyWith(loadingMore: true, error: null);
    try {
      final data = await getAllPosts(skip: _skip, limit: _limit);
      _skip += data.length;

      state = state.copyWith(
        loadingMore: false,
        posts: [...state.posts, ...data],
        hasMore: data.length == _limit,
      );

      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(
        loadingMore: false,
        error: 'Offline. Showing cached posts.',
      );
    }
  }

  Future<void> onCreatePost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments = const [],
  }) async {
    state = state.copyWith(error: null);
    try {
      final created = await createPost(
        title: title,
        description: description,
        content: content,
        asDraft: asDraft,
        attachments: attachments,
      );

      state = state.copyWith(posts: [created, ...state.posts]);
      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> onUpdatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments = const [],
    List<String> keepExistingAttachmentIds = const [],
  }) async {
    state = state.copyWith(error: null);
    try {
      final updated = await updatePost(
        postId: postId,
        title: title,
        description: description,
        content: content,
        asDraft: asDraft,
        newAttachments: newAttachments,
        keepExistingAttachmentIds: keepExistingAttachmentIds,
      );

      final next = state.posts.map((p) => p.id == postId ? updated : p).toList();
      state = state.copyWith(posts: next);
      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> onDeletePost(String postId) async {
    state = state.copyWith(error: null);
    try {
      await deletePost(postId);

      state = state.copyWith(posts: state.posts.where((p) => p.id != postId).toList());
      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> onToggleLike(String postId) async {
    try {
      final updated = await toggleLike(postId);
      final next = state.posts.map((p) => p.id == postId ? updated : p).toList();
      state = state.copyWith(posts: next);
      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> onToggleSave(String postId) async {
    try {
      final updated = await toggleSave(postId);
      final next = state.posts.map((p) => p.id == postId ? updated : p).toList();
      state = state.copyWith(posts: next);
      await _writeCacheFromState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}