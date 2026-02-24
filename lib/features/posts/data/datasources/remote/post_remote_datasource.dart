import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/post_datasource.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_api_model.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostRemoteDatasource implements IPostRemoteDatasource {
  final UserSessionService _userSessionService;

  PostRemoteDatasource({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  Future<String> _getToken() async => _userSessionService.getUserToken() ?? '';

  @override
  Future<PostEntity> createPost({
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
    final parts = mimeType.split('/');

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
    return PostApiModel.fromJson(data).toEntity();
  }

  @override
  Future<PostEntity> updatePost({
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
    return PostApiModel.fromJson(data).toEntity();
  }

  @override
Future<List<PostEntity>> getAllPosts({
  int skip = 0,
  int limit = 10,
}) async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.getAllPosts()}?skip=$skip&limit=$limit',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch posts: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'] as List;
  return data.map((json) => _mapJsonToPost(json)).toList();
}

@override
Future<List<PostEntity>> getDrafts() async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.getDrafts()}',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch drafts: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'] as List;
  return data.map((json) => _mapJsonToPost(json)).toList();
}

@override
Future<List<PostEntity>> getFeed({
  String? lastCreatedAt,
  int limit = 10,
}) async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.getFeed()}'
    '?limit=$limit'
    '${lastCreatedAt != null ? '&lastCreatedAt=$lastCreatedAt' : ''}',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch feed: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'] as List;
  return data.map((json) => _mapJsonToPost(json)).toList();
}

@override
Future<List<PostEntity>> getRankedFeed({
  int skip = 0,
  int limit = 10,
}) async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.rankedFeed}?skip=$skip&limit=$limit',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch ranked feed: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'] as List;
  return data.map((json) => _mapJsonToPost(json)).toList();
}

@override
Future<PostEntity> getPostById(String postId) async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.getPostById(postId)}',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch post: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'];
  return _mapJsonToPost(data);
}

@override
Future<void> toggleLike(String postId) async {
  final res = await http.post(
    Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.toggleLike(postId)}'),
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to toggle like');
  }
}

@override
Future<void> toggleSave(String postId) async {
  final res = await http.post(
    Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.toggleSave(postId)}'),
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to toggle save');
  }
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

  PostEntity _mapJsonToPost(Map<String, dynamic> json) {
  final apiModel = PostApiModel.fromJson(json);
  return apiModel.toEntity();
}

@override
Future<List<PostEntity>> getMyPosts(String userId, {int skip = 0, int limit = 10}) async {
  final uri = Uri.parse(
    '${ApiEndpoints.baseUrl}${ApiEndpoints.getMyPosts(userId!)}?skip=$skip&limit=$limit',
  );

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer ${await _getToken()}'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch user posts: ${res.body}');
  }

  final data = jsonDecode(res.body)['data'] as List;
  return data.map((json) => _mapJsonToPost(json)).toList();
}
}