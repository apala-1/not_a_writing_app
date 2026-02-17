import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

abstract class IPostRemoteDatasource {
  Future<Post> createPost({
    required String title,
    required String description,
    required String content,
    required bool isDraft,
    List<File>? attachments,
  });

  Future<Post> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    bool? isDraft,
    List<File>? attachments,
  });

  Future<void> addShare(String postId);
  Future<void> addView(String postId);
}

class PostRemoteDatasource implements IPostRemoteDatasource {
  final UserSessionService _userSessionService;

  PostRemoteDatasource({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  Future<String> _getToken() async => await _userSessionService.getUserToken() ?? '';

  @override
  Future<Post> createPost({
    required String title,
    required String description,
    required String content,
    required bool isDraft,
    List<File>? attachments,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.createPost()}');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${await _getToken()}';

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['content'] = content;
    request.fields['status'] = isDraft ? 'draft' : 'published';

    if (attachments != null) {
  for (var file in attachments) {
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final parts = mimeType.split('/'); // e.g., ['image', 'jpeg']

    request.files.add(
      await http.MultipartFile.fromPath(
        'attachments',
        file.path,
        contentType: http.MediaType(parts[0], parts[1]),
      ),
    );
  }
}

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Failed to create post: ${response.body}');
    }

    final data = jsonDecode(response.body)['data'];
    return _mapJsonToPost(data);
  }

  @override
  Future<Post> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    bool? isDraft,
    List<File>? attachments,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.updatePost(postId)}');
    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer ${await _getToken()}';

    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (content != null) request.fields['content'] = content;
    if (isDraft != null) request.fields['status'] = isDraft ? 'draft' : 'published';

    if (attachments != null) {
      for (var file in attachments) {
        request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to update post: ${response.body}');
    }

    final data = jsonDecode(response.body)['data'];
    return _mapJsonToPost(data);
  }

  @override
  Future<void> addShare(String postId) async {
    final res = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.addShare(postId)}'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );
    if (res.statusCode != 200) throw Exception('Failed to share post');
  }

  @override
  Future<void> addView(String postId) async {
    final res = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.addView(postId)}'),
      headers: {'Authorization': 'Bearer ${await _getToken()}'},
    );
    if (res.statusCode != 200) throw Exception('Failed to add view');
  }

  Post _mapJsonToPost(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      isDraft: json['status'] == 'draft',
      attachments: (json['attachments'] as List? ?? [])
          .map((a) => Attachment(url: a['url'], type: a['type']))
          .toList(),
      viewsCount: json['viewsCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      savesCount: json['savesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }
}