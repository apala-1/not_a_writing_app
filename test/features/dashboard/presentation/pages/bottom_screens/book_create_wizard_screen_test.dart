import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_create_wizard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_args.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/presentation/providers/posts_providers.dart';

void main() {
  Future<_WizardHarness> pumpWizard(
  WidgetTester tester, {
  required dynamic getMyPostsUsecaseOverride,
}) async {
  final results = <Object?>[];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [getMyPostsUsecaseOverride],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  final res = await Navigator.of(context).push<Object?>(
                    MaterialPageRoute(builder: (_) => const BookCreateWizardScreen()),
                  );
                  results.add(res);
                },
                child: const Text('OpenWizard'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // Don't pumpAndSettle here; the pushed page may contain an animating spinner.
  await tester.pump();

  await tester.tap(find.text('OpenWizard'));
  await tester.pump(); // start navigation transition
  await tester.pump(const Duration(milliseconds: 400)); // finish transition

  return _WizardHarness(results: results);
}

testWidgets('shows loading indicator until posts load', (tester) async {
  final completer = Completer<List<PostEntity>>();

  final override = getMyPostsUsecaseProvider.overrideWithValue(
    FakeGetMyPostsUsecase(
      FakePostsRepository(future: completer.future),
    ),
  );

  await pumpWizard(tester, getMyPostsUsecaseOverride: override);

  // Let FutureBuilder run once
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Now complete the future and settle
  completer.complete(<PostEntity>[]);
  await tester.pump(); // process future completion
  await tester.pumpAndSettle();
});


  testWidgets('shows loading indicator until posts load', (tester) async {
    final completer = Completer<List<PostEntity>>();

    final override = getMyPostsUsecaseProvider.overrideWithValue(
      FakeGetMyPostsUsecase(
        FakePostsRepository(future: completer.future),
      ),
    );

    await pumpWizard(tester, getMyPostsUsecaseOverride: override);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(<PostEntity>[]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows "No posts found." when posts list is empty', (tester) async {
    final override = getMyPostsUsecaseProvider.overrideWithValue(
      FakeGetMyPostsUsecase(
        FakePostsRepository(posts: const <PostEntity>[]),
      ),
    );

    await pumpWizard(tester, getMyPostsUsecaseOverride: override);
    await tester.pumpAndSettle();

    expect(find.text('No posts found.'), findsOneWidget);
  });

  testWidgets('Next disabled until selection; selecting enables it', (tester) async {
    final posts = <PostEntity>[
      _post(id: 'p1', title: 'Post 1'),
      _post(id: 'p2', title: 'Post 2'),
    ];

    final override = getMyPostsUsecaseProvider.overrideWithValue(
      FakeGetMyPostsUsecase(
        FakePostsRepository(posts: posts),
      ),
    );

    await pumpWizard(tester, getMyPostsUsecaseOverride: override);
    await tester.pumpAndSettle();

    final next0 = find.widgetWithText(FilledButton, 'Next (0 posts)');
    expect(next0, findsOneWidget);
    expect(tester.widget<FilledButton>(next0).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile).at(0));
    await tester.pumpAndSettle();

    final next1 = find.widgetWithText(FilledButton, 'Next (1 posts)');
    expect(next1, findsOneWidget);
    expect(tester.widget<FilledButton>(next1).onPressed, isNotNull);
  });

  testWidgets('Create from scratch pops a BookEditorArgs', (tester) async {
    final override = getMyPostsUsecaseProvider.overrideWithValue(
      FakeGetMyPostsUsecase(
        FakePostsRepository(posts: const <PostEntity>[]),
      ),
    );

    final h = await pumpWizard(tester, getMyPostsUsecaseOverride: override);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create from scratch'));
    await tester.pumpAndSettle();

    expect(h.results, hasLength(1));
    expect(h.results.single, isA<BookEditorArgs>());
  });
}

class _WizardHarness {
  final List<Object?> results;
  _WizardHarness({required this.results});
}

/// Real subtype of your real usecase class.
class FakeGetMyPostsUsecase extends GetMyPostsUsecase {
  FakeGetMyPostsUsecase(super.repo);
}

class FakePostsRepository implements PostsRepository {
  FakePostsRepository({this.posts, this.future});

  final List<PostEntity>? posts;
  final Future<List<PostEntity>>? future;

  @override
  Future<List<PostEntity>> getMyPosts() {
    if (future != null) return future!;
    return Future.value(posts ?? const <PostEntity>[]);
  }

  // Unused methods - keep stubs just to satisfy the interface.
  @override
  Future<PostEntity> createPost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments = const [],
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deletePost(String postId) => throw UnimplementedError();

  @override
  Future<List<PostEntity>> getAllPosts({int skip = 0, int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<List<PostEntity>> getDrafts() => throw UnimplementedError();

  @override
  Future<PostEntity> getPostById(String id) => throw UnimplementedError();

  @override
  Future<PostEntity> toggleLike(String postId) => throw UnimplementedError();

  @override
  Future<PostEntity> toggleSave(String postId) => throw UnimplementedError();

  @override
  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments = const [],
    List<String> keepExistingAttachmentIds = const [],
  }) =>
      throw UnimplementedError();
}

PostEntity _post({
  required String id,
  String? title,
  String? content,
  int attachmentsCount = 0,
}) {
  return PostEntity(
    id: id,
    title: title,
    content: content ?? '',
    attachments: List.generate(attachmentsCount, (_) => _attachment()),
    author: null,
    description: '',
    status: '',
    visibility: '',
    viewsCount: 0,
    likesCount: 0,
    savesCount: 0,
    sharesCount: 0,
    commentsCount: 0,
    isLiked: false,
    isSaved: false,
    createdAt: null,
  );
}

PostAttachmentEntity _attachment() {
  return const PostAttachmentEntity(
    id: '',
    url: '',
    type: '',
  );
}