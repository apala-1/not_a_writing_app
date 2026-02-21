import 'package:not_a_writing_app/features/dashboard/data/datasources/comment_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remote;

  CommentRepositoryImpl(this.remote);

  @override
  Future<List<CommentEntity>> getComments(String postId) {
    return remote.getComments(postId);
  }

  @override
  Future<CommentEntity> createComment(String postId, String content) {
    return remote.createComment(postId, content);
  }

  @override
  Future<CommentEntity> updateComment(String commentId, String content) {
    return remote.updateComment(commentId, content);
  }

  @override
  Future<void> deleteComment(String commentId) {
    return remote.deleteComment(commentId);
  }
}
