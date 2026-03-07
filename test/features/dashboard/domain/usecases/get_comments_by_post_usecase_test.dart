import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_user_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_comments_by_post_usecase.dart';

class _MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository repo;
  late GetCommentsByPostUsecase usecase;

  setUp(() {
    repo = _MockCommentsRepository();
    usecase = GetCommentsByPostUsecase(repo);
  });

  test('calls repo.getByPost with same postId and returns list', () async {
    // arrange
    const comments = <CommentEntity>[
      CommentEntity(
        id: 'c1',
        postId: 'p1',
        user: CommentUserEntity(id: 'u1', name: 'User', profilePicture: null),
        content: 'hello',
        parentCommentId: null,
        replies: [],
        createdAt: null,
      ),
    ];

    when(() => repo.getByPost(any())).thenAnswer((_) async => comments);

    // act
    final result = await usecase.call('p1');

    // assert
    expect(result, comments);

    verify(() => repo.getByPost('p1')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('rethrows when repo.getByPost throws', () async {
    // arrange
    when(() => repo.getByPost(any())).thenThrow(Exception('fail'));

    // act + assert
    expect(
      () => usecase.call('p1'),
      throwsA(isA<Exception>()),
    );
  });
}