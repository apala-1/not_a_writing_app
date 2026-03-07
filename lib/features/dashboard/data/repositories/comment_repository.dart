import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/comment_remotedatasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remote;
  CommentsRepositoryImpl(this.remote);

  @override
  Future<List<CommentEntity>> getByPost(String postId) async {
    final models = await remote.getByPost(postId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CommentEntity> create({required String postId, required String content}) async {
    final m = await remote.create(postId: postId, content: content);
    return m.toEntity();
  }

  @override
  Future<CommentEntity> reply({required String postId, required String parentCommentId, required String content}) async {
    final m = await remote.reply(postId: postId, parentCommentId: parentCommentId, content: content);
    return m.toEntity();
  }

  @override
  Future<CommentEntity> update({required String commentId, required String content}) async {
    final m = await remote.update(commentId: commentId, content: content);
    return m.toEntity();
  }

  @override
  Future<void> delete(String commentId) => remote.delete(commentId);
}