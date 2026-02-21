import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/comment_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(ref.read(commentRemoteDatasourceProvider));
});

abstract class CommentRepository {
  Future<List<CommentEntity>> getComments(String postId);
  Future<CommentEntity> createComment(String postId, String content);
  Future<CommentEntity> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<List<CommentEntity>> getWholeCommentWithProfile(String userId);
}
