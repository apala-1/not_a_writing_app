import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:not_a_writing_app/features/posts/data/cache/dashboard_feed_cache.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_hive_model.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_save_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/update_post_usecase.dart';

class _MockGetAllPostsUsecase extends Mock implements GetAllPostsUsecase {}

class _MockCreatePostUsecase extends Mock implements CreatePostUsecase {}

class _MockUpdatePostUsecase extends Mock implements UpdatePostUsecase {}

class _MockDeletePostUsecase extends Mock implements DeletePostUsecase {}

class _MockToggleLikeUsecase extends Mock implements ToggleLikeUsecase {}

class _MockToggleSaveUsecase extends Mock implements ToggleSaveUsecase {}

class _MockDashboardFeedCache extends Mock implements DashboardFeedCache {}

class _FakeFile extends Fake implements File {}

void main() {
  late GetAllPostsUsecase getAllPosts;
  late CreatePostUsecase createPost;
  late UpdatePostUsecase updatePost;
  late DeletePostUsecase deletePost;
  late ToggleLikeUsecase toggleLike;
  late ToggleSaveUsecase toggleSave;
  late DashboardFeedCache cache;

  late DashboardViewModel vm;

  setUpAll(() {
    registerFallbackValue(_FakeFile());
    registerFallbackValue(<File>[_FakeFile()]);
    // If any of your usecases use complex params objects with any(), add fallbacks here too.
  });

  // NOTE: Adjust this helper to match your real PostEntity constructor.
  PostEntity _post(String id, {int likesCount = 0, int savesCount = 0}) {
    return PostEntity(
      id: id,
      title: null,
      description: 'd',
      content: 'c',
      status: 'published',
      visibility: 'public',
      attachments: const [],
      likesCount: likesCount,
      commentsCount: 0,
      sharesCount: 0,
      savesCount: savesCount,
      viewsCount: 0,
      createdAt: DateTime(2026, 3, 7),
      author: null, isLiked: false, isSaved: false, 
    );
  }

  setUp(() {
  getAllPosts = _MockGetAllPostsUsecase();
  createPost = _MockCreatePostUsecase();
  updatePost = _MockUpdatePostUsecase();
  deletePost = _MockDeletePostUsecase();
  toggleLike = _MockToggleLikeUsecase();
  toggleSave = _MockToggleSaveUsecase();
  cache = _MockDashboardFeedCache();

  // IMPORTANT: stub async cache methods (otherwise mocktail returns null)
  when(() => cache.readPosts()).thenAnswer((_) async => <PostHive>[]);
  when(() => cache.writePosts(any())).thenAnswer((_) async {});

  vm = DashboardViewModel(
    getAllPosts: getAllPosts,
    createPost: createPost,
    updatePost: updatePost,
    deletePost: deletePost,
    toggleLike: toggleLike,
    toggleSave: toggleSave,
    cache: cache,
  );
});

  test('initial state is DashboardState.initial()', () {
    expect(vm.state, DashboardState.initial());
  });

  test('refresh(): sets loading true then sets posts + hasMore on success', () async {
    final posts = List.generate(10, (i) => _post('p$i'));

    when(() => getAllPosts(skip: 0, limit: 10)).thenAnswer((_) async => posts);

    final future = vm.refresh();

    // immediate sync state change
    expect(vm.state.loading, true);
    expect(vm.state.error, isNull);

    await future;

    expect(vm.state.loading, false);
    expect(vm.state.posts, posts);
    expect(vm.state.hasMore, true);

    verify(() => getAllPosts(skip: 0, limit: 10)).called(1);
    verifyNoMoreInteractions(getAllPosts);
  });

  test('refresh(): sets hasMore false when fewer than limit returned', () async {
    final posts = <PostEntity>[_post('p1'), _post('p2')];

    when(() => getAllPosts(skip: 0, limit: 10)).thenAnswer((_) async => posts);

    await vm.refresh();

    expect(vm.state.loading, false);
    expect(vm.state.posts, posts);
    expect(vm.state.hasMore, false);

    verify(() => getAllPosts(skip: 0, limit: 10)).called(1);
  });

  test('refresh(): sets error when getAllPosts throws', () async {
    when(() => getAllPosts(skip: 0, limit: 10)).thenThrow(Exception('boom'));

    await vm.refresh();

    expect(vm.state.loading, false);
    expect(vm.state.posts, isEmpty);
    expect(vm.state.error, contains('boom'));

    verify(() => getAllPosts(skip: 0, limit: 10)).called(1);
  });

  test('loadMore(): does nothing when hasMore is false', () async {
    vm.state = vm.state.copyWith(hasMore: false, posts: [_post('p1')]);

    await vm.loadMore();

    verifyZeroInteractions(getAllPosts);
  });

  test('onCreatePost(): inserts created post at top', () async {
    vm.state = vm.state.copyWith(posts: [_post('p1'), _post('p2')]);

    final created = _post('p_new');

    when(() => createPost(
          title: any(named: 'title'),
          description: any(named: 'description'),
          content: any(named: 'content'),
          asDraft: any(named: 'asDraft'),
          attachments: any(named: 'attachments'),
        )).thenAnswer((_) async => created);

    await vm.onCreatePost(
      title: 't',
      description: 'd',
      content: 'content',
      asDraft: false,
      attachments: const [],
    );

    expect(vm.state.posts.first.id, 'p_new');

    verify(() => createPost(
          title: 't',
          description: 'd',
          content: 'content',
          asDraft: false,
          attachments: const [],
        )).called(1);
  });

  test('onUpdatePost(): replaces the matching post', () async {
    vm.state = vm.state.copyWith(posts: [_post('p1'), _post('p2')]);

    final updated = _post('p2');

    when(() => updatePost(
          postId: any(named: 'postId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          content: any(named: 'content'),
          asDraft: any(named: 'asDraft'),
          newAttachments: any(named: 'newAttachments'),
          keepExistingAttachmentIds: any(named: 'keepExistingAttachmentIds'),
        )).thenAnswer((_) async => updated);

    await vm.onUpdatePost(
      postId: 'p2',
      title: 't',
      description: 'd',
      content: 'c',
      asDraft: false,
      newAttachments: const [],
      keepExistingAttachmentIds: const [],
    );

    expect(vm.state.posts.map((p) => p.id).toList(), ['p1', 'p2']);

    verify(() => updatePost(
          postId: 'p2',
          title: 't',
          description: 'd',
          content: 'c',
          asDraft: false,
          newAttachments: const [],
          keepExistingAttachmentIds: const [],
        )).called(1);
  });

  test('onDeletePost(): removes post from state on success', () async {
    vm.state = vm.state.copyWith(posts: [_post('p1'), _post('p2')]);

    when(() => deletePost('p1')).thenAnswer((_) async {});

    await vm.onDeletePost('p1');

    expect(vm.state.posts.map((p) => p.id).toList(), ['p2']);
    expect(vm.state.error, isNull);

    verify(() => deletePost('p1')).called(1);
  });

  test('onToggleLike(): updates matching post on success', () async {
    vm.state = vm.state.copyWith(posts: [_post('p1'), _post('p2')]);

    final updated = _post('p2', likesCount: 1);

    when(() => toggleLike('p2')).thenAnswer((_) async => updated);

    await vm.onToggleLike('p2');

    expect(vm.state.posts.firstWhere((p) => p.id == 'p2').likesCount, 1);
    expect(vm.state.error, isNull);

    verify(() => toggleLike('p2')).called(1);
  });

  test('onToggleSave(): updates matching post on success', () async {
    vm.state = vm.state.copyWith(posts: [_post('p1'), _post('p2')]);

    final updated = _post('p2', savesCount: 1);

    when(() => toggleSave('p2')).thenAnswer((_) async => updated);

    await vm.onToggleSave('p2');

    expect(vm.state.posts.firstWhere((p) => p.id == 'p2').savesCount, 1);
    expect(vm.state.error, isNull);

    verify(() => toggleSave('p2')).called(1);
  });
}