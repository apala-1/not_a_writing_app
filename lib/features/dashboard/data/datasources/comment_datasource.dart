import 'package:not_a_writing_app/features/dashboard/data/models/comment_api_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentApiModel>> getComments(String postId);
  Future<CommentApiModel> createComment(String postId, String content);
  Future<CommentApiModel> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
}
