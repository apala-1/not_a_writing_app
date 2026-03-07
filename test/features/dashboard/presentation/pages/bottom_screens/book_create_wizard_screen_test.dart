import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_create_wizard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_args.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/presentation/providers/posts_providers.dart';

class FakeGetMyPostsUsecase implements GetMyPostsUsecase {
  final Future<List<PostEntity>> Function() _fn;
  FakeGetMyPostsUsecase(this._fn);

  @override
  Future<List<PostEntity>> call() => _fn();

  @override
  // TODO: implement repo
  PostsRepository get repo => throw UnimplementedError();
}

void main() {
  group('BookCreateWizardScreen (widget)', () {
    PostEntity post({
      required String id,
      String? title,
      String? content,
      int attachmentsCount = 0,
    }) {
      return PostEntity(
        id: id,
        author: null,
        title: title,
        description: null,
        content: content,
        attachments: List.generate(
          attachmentsCount,
          (i) => PostAttachmentEntity(id: 'a$i', url: 'http://example.com/$i.jpg', type: 'image'),
        ),
        status: 'published',
        visibility: 'public',
        viewsCount: 0,
        likesCount: 0,
        savesCount: 0,
        sharesCount: 0,
        commentsCount: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime(2026, 3, 7),
      );
    }

    testWidgets('loads posts, toggles selection, enables Next and pops args', (tester) async {
      final posts = <PostEntity>[
        post(id: 'p1', title: 'First Post', attachmentsCount: 2, content: 'hello'),
        post(id: 'p2', title: 'Second Post', attachmentsCount: 0, content: 'world'),
      ];

      final container = ProviderContainer(
        overrides: [
          getMyPostsUsecaseProvider.overrideWithValue(
            FakeGetMyPostsUsecase(() async => posts),
          ),
        ],
      );
      addTearDown(container.dispose);

      final resultCompleter = Completer<Object?>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.of(context).push<Object?>(
                          MaterialPageRoute(builder: (_) => const BookCreateWizardScreen()),
                        );
                        resultCompleter.complete(res);
                      },
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Let FutureBuilder resolve
      await tester.pumpAndSettle();

      expect(find.text('Start Your Story'), findsOneWidget);
      expect(find.text('Convert existing content'), findsOneWidget);
      expect(find.text('First Post'), findsOneWidget);
      expect(find.text('Second Post'), findsOneWidget);
      expect(find.text('2 attachments'), findsOneWidget);
      expect(find.text('0 attachments'), findsOneWidget);

      // disabled initially
      final next0 = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next (0 posts)'),
      );
      expect(next0.onPressed, isNull);

      // select 1 post
      await tester.tap(find.text('First Post'));
      await tester.pumpAndSettle();

      final next1Finder = find.widgetWithText(ElevatedButton, 'Next (1 posts)');
      expect(next1Finder, findsOneWidget);
      final next1 = tester.widget<ElevatedButton>(next1Finder);
      expect(next1.onPressed, isNotNull);

      // tap next => pop args
      await tester.tap(next1Finder);
      await tester.pumpAndSettle();

      final popped = await resultCompleter.future;
      expect(popped, isA<BookEditorArgs>());

      // TODO: change these to your real BookEditorArgs fields
      // final args = popped as BookEditorArgs;
      // expect(args.<YOUR_FIELD_HERE>, isNotEmpty);
    });

    testWidgets('Create from scratch pops BookEditorArgs', (tester) async {
      final container = ProviderContainer(
        overrides: [
          getMyPostsUsecaseProvider.overrideWithValue(
            FakeGetMyPostsUsecase(() async => <PostEntity>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final resultCompleter = Completer<Object?>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await Navigator.of(context).push<Object?>(
                          MaterialPageRoute(builder: (_) => const BookCreateWizardScreen()),
                        );
                        resultCompleter.complete(res);
                      },
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create from scratch'));
      await tester.pumpAndSettle();

      final popped = await resultCompleter.future;
      expect(popped, isA<BookEditorArgs>());

      // TODO: change to your real field(s) in BookEditorArgs
      // final args = popped as BookEditorArgs;
      // expect(args.<YOUR_FIELD_HERE>.length, 1);
    });
  });
}