import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/update_comments_usecase.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class _MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository repo;
  late UpdateCommentUsecase usecase;

  setUp(() {
    repo = _MockCommentsRepository();
    usecase = UpdateCommentUsecase(repo);
  });

  test('calls repo.update with same commentId/content and returns CommentEntity', () async {
    // arrange
    const expected = CommentEntity(
      id: 'c1',
      postId: 'p1',
      user: CommentUserEntity(id: 'u1', name: 'User', profilePicture: null),
      content: 'updated',
      parentCommentId: null,
      replies: [],
      createdAt: null,
    );

    when(() => repo.update(
          commentId: any(named: 'commentId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => expected);

    // act
    final result = await usecase.call(commentId: 'c1', content: 'updated');

    // assert
    expect(result, expected);

    verify(() => repo.update(commentId: 'c1', content: 'updated')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.update throws', () async {
    // arrange
    when(() => repo.update(
          commentId: any(named: 'commentId'),
          content: any(named: 'content'),
        )).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call(commentId: 'c1', content: 'updated'),
      throwsA(isA<Exception>()),
    );
  });
}