import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/comments_state.dart';

class _MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository repo;

  const postId = 'p1';

  CommentEntity _comment({
    required String id,
    String content = 'hello',
    String? parentCommentId,
    List<CommentEntity> replies = const [],
  }) {
    return CommentEntity(
      id: id,
      postId: postId,
      user: const CommentUserEntity(id: 'u1', name: 'User', profilePicture: null),
      content: content,
      parentCommentId: parentCommentId,
      replies: replies,
      createdAt: null,
    );
  }

  setUp(() {
    repo = _MockCommentsRepository();
  });

  test('initial state is CommentsState.initial()', () {
    final vm = CommentsVm(repo: repo, postId: postId);
    expect(vm.state, CommentsState.initial());
  });

  test('load(): sets loading true then sets comments on success', () async {
    final vm = CommentsVm(repo: repo, postId: postId);
    final comments = <CommentEntity>[
      _comment(id: 'c1'),
      _comment(id: 'c2', content: 'second'),
    ];

    when(() => repo.getByPost(postId)).thenAnswer((_) async => comments);

    final future = vm.load();

    // sync state update
    expect(vm.state.loading, true);
    expect(vm.state.error, isNull);

    await future;

    expect(vm.state.loading, false);
    expect(vm.state.error, isNull);
    expect(vm.state.comments, comments);

    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('load(): sets error when repo.getByPost throws', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.getByPost(postId)).thenThrow(Exception('boom'));

    await vm.load();

    expect(vm.state.loading, false);
    expect(vm.state.comments, isEmpty);
    expect(vm.state.error, contains('boom'));

    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('addComment(): does nothing when content is empty/whitespace', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    await vm.addComment('   ');

    verifyZeroInteractions(repo);
    expect(vm.state, CommentsState.initial());
  });

  test('addComment(): calls repo.create then reloads', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.create(postId: postId, content: 'hi')).thenAnswer((_) async => _comment(id: 'new'));
    when(() => repo.getByPost(postId)).thenAnswer((_) async => <CommentEntity>[_comment(id: 'c1')]);

    await vm.addComment(' hi ');

    verify(() => repo.create(postId: postId, content: 'hi')).called(1);
    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);

    expect(vm.state.loading, false);
    expect(vm.state.error, isNull);
    expect(vm.state.comments, hasLength(1));
  });

  test('reply(): does nothing when content is empty/whitespace', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    await vm.reply('c1', '   ');

    verifyZeroInteractions(repo);
    expect(vm.state, CommentsState.initial());
  });

  test('reply(): calls repo.reply then reloads', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.reply(
          postId: postId,
          parentCommentId: 'c1',
          content: 'reply',
        )).thenAnswer((_) async => _comment(id: 'r1', parentCommentId: 'c1', content: 'reply'));

    when(() => repo.getByPost(postId)).thenAnswer((_) async => <CommentEntity>[_comment(id: 'c1')]);

    await vm.reply('c1', ' reply ');

    verify(() => repo.reply(
          postId: postId,
          parentCommentId: 'c1',
          content: 'reply',
        )).called(1);

    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('edit(): does nothing when content is empty/whitespace', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    await vm.edit('c1', '   ');

    verifyZeroInteractions(repo);
    expect(vm.state, CommentsState.initial());
  });

  test('edit(): calls repo.update then reloads on success', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.update(commentId: 'c1', content: 'edited')).thenAnswer((_) async => _comment(id: 'c1', content: 'edited'));
    when(() => repo.getByPost(postId)).thenAnswer((_) async => <CommentEntity>[_comment(id: 'c1', content: 'edited')]);

    await vm.edit('c1', ' edited ');

    verify(() => repo.update(commentId: 'c1', content: 'edited')).called(1);
    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);

    expect(vm.state.error, isNull);
  });

  test('edit(): sets error when repo.update throws (does not reload)', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.update(commentId: 'c1', content: 'edited')).thenThrow(Exception('update failed'));

    await vm.edit('c1', ' edited ');

    expect(vm.state.error, contains('update failed'));

    verify(() => repo.update(commentId: 'c1', content: 'edited')).called(1);
    // should NOT call load() if update throws
    verifyNever(() => repo.getByPost(any()));
    verifyNoMoreInteractions(repo);
  });

  test('remove(): calls repo.delete then reloads', () async {
    final vm = CommentsVm(repo: repo, postId: postId);

    when(() => repo.delete('c1')).thenAnswer((_) async {});
    when(() => repo.getByPost(postId)).thenAnswer((_) async => <CommentEntity>[]);

    await vm.remove('c1');

    verify(() => repo.delete('c1')).called(1);
    verify(() => repo.getByPost(postId)).called(1);
    verifyNoMoreInteractions(repo);
  });
}