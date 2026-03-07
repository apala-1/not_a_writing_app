import 'package:mocktail/mocktail.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_comments_usecase.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class _MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository repo;
  late CreateCommentUsecase usecase;

  setUp(() {
    repo = _MockCommentsRepository();
    usecase = CreateCommentUsecase(repo);
  });

  test('calls repo.create with same postId/content and returns CommentEntity', () async {
    // arrange
    const expected = CommentEntity(
      id: 'c1',
      postId: 'p1',
      user: CommentUserEntity(
        id: 'u1',
        name: 'User',
        profilePicture: null,
      ),
      content: 'hello',
      parentCommentId: null,
      replies: [],
      createdAt: null,
    );

    when(() => repo.create(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => expected);

    // act
    final result = await usecase.call(postId: 'p1', content: 'hello');

    // assert
    expect(result, expected);

    verify(() => repo.create(postId: 'p1', content: 'hello')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.create throws', () async {
    // arrange
    when(() => repo.create(
          postId: any(named: 'postId'),
          content: any(named: 'content'),
        )).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call(postId: 'p1', content: 'hello'),
      throwsA(isA<Exception>()),
    );
  });
}