import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/comment_api_model.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentApiModel>> getByPost(String postId);
  Future<CommentApiModel> create({required String postId, required String content});
  Future<CommentApiModel> reply({
    required String postId,
    required String parentCommentId,
    required String content,
  });
  Future<CommentApiModel> update({required String commentId, required String content});
  Future<void> delete(String commentId);
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiClient api;
  CommentsRemoteDataSourceImpl(this.api);

  dynamic _unwrap(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) return body['data'];
    return body;
  }

  @override
  Future<List<CommentApiModel>> getByPost(String postId) async {
    final res = await api.dio.get(ApiEndpoints.getCommentsByPost(postId));
    print('COMMENTS RAW: ${res.data}');
    final data = _unwrap(res) as List;
    return data.map((e) => CommentApiModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<CommentApiModel> create({required String postId, required String content}) async {
    final res = await api.dio.post(ApiEndpoints.createComment(), data: {
      'postId': postId,
      'content': content,
    });
    final data = _unwrap(res) as Map<String, dynamic>;
    return CommentApiModel.fromJson(data);
  }

  @override
  Future<CommentApiModel> reply({
    required String postId,
    required String parentCommentId,
    required String content,
  }) async {
    final res = await api.dio.post(ApiEndpoints.replyComment(), data: {
      'postId': postId,
      'parentCommentId': parentCommentId,
      'content': content,
    });
    final data = _unwrap(res) as Map<String, dynamic>;
    return CommentApiModel.fromJson(data);
  }

  @override
  Future<CommentApiModel> update({required String commentId, required String content}) async {
    final res = await api.dio.patch(ApiEndpoints.updateComment(commentId), data: {'content': content});
    final data = _unwrap(res) as Map<String, dynamic>;
    return CommentApiModel.fromJson(data);
  }

  @override
  Future<void> delete(String commentId) async {
    await api.dio.delete(ApiEndpoints.deleteComment(commentId));
  }
}