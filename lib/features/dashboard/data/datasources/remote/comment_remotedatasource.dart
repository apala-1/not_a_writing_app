import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/comment_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/comment_api_model.dart';

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final UserSessionService _userSessionService;

  CommentRemoteDataSourceImpl({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  Future<String> _getToken() async =>
      await _userSessionService.getUserToken() ?? '';

  @override
  Future<List<CommentApiModel>> getComments(String postId) async {
    final uri =
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getCommentsByPost(postId)}');

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${await _getToken()}', 'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch comments: ${res.body}');
    }

    final data = jsonDecode(res.body)['data'] as List;
    return data.map((json) => CommentApiModel.fromJson(json)).toList();
  }

  @override
  Future<CommentApiModel> createComment(String postId, String content) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.createComment()}');

    final res = await http.post(
      uri,
      headers: {'Authorization': 'Bearer ${await _getToken()}', 'Content-Type': 'application/json'},
      body: jsonEncode({'postId': postId, 'content': content}),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create comment: ${res.body}');
    }

    final data = jsonDecode(res.body)['data'];
    return CommentApiModel.fromJson(data);
  }

  @override
  Future<CommentApiModel> updateComment(String commentId, String content) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.updateComment(commentId)}');
    print('Updating comment at $uri');
    final res = await http.patch(
      uri,
      headers: {'Authorization': 'Bearer ${await _getToken()}', 'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update comment: ${res.body}');
    }

    final data = jsonDecode(res.body)['data'];
    return CommentApiModel.fromJson(data);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.deleteComment(commentId)}');

    final res = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer ${await _getToken()}', 'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete comment: ${res.body}');
    }
  }
}
