import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/reply_to_comment_usecase.dart';

class _MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository repo;
  late ReplyToCommentUsecase usecase;

  setUp(() {
    repo = _MockCommentsRepository();
    usecase = ReplyToCommentUsecase(repo);
  });

  test('calls repo.reply with same params and returns CommentEntity', () async {
    // arrange
    const expected = CommentEntity(
      id: 'r1',
      postId: 'p1',
      user: CommentUserEntity(id: 'u1', name: 'User', profilePicture: null),
      content: 'reply',
      parentCommentId: 'c1',
      replies: [],
      createdAt: null,
    );

    when(() => repo.reply(
          postId: any(named: 'postId'),
          parentCommentId: any(named: 'parentCommentId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => expected);

    // act
    final result = await usecase.call(
      postId: 'p1',
      parentCommentId: 'c1',
      content: 'reply',
    );

    // assert
    expect(result, expected);

    verify(() => repo.reply(
          postId: 'p1',
          parentCommentId: 'c1',
          content: 'reply',
        )).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.reply throws', () async {
    // arrange
    when(() => repo.reply(
          postId: any(named: 'postId'),
          parentCommentId: any(named: 'parentCommentId'),
          content: any(named: 'content'),
        )).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call(postId: 'p1', parentCommentId: 'c1', content: 'reply'),
      throwsA(isA<Exception>()),
    );
  });
}