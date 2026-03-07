import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class CreateCommentUsecase {
  final CommentsRepository repo;
  CreateCommentUsecase(this.repo);

  Future<CommentEntity> call({required String postId, required String content}) {
    return repo.create(postId: postId, content: content);
  }
}