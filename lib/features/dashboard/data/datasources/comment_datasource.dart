import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/comment_remotedatasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/comment_api_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentApiModel>> getComments(String postId);
  Future<CommentApiModel> createComment(String postId, String content);
  Future<CommentApiModel> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<List<CommentApiModel>> getWholeCommentWithProfile(String userId);
}
