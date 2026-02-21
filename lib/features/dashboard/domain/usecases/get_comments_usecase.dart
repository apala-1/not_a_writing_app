import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call(String postId) {
    return repository.getComments(postId);
  }
}
