import 'dart:io';
import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_api_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostApiModel>> getAllPosts({int skip, int limit});
  Future<PostApiModel> getPostById(String id);

  Future<List<PostApiModel>> getDrafts();
  Future<List<PostApiModel>> getMyPosts();

  Future<PostApiModel> createPost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments,
  });

  Future<PostApiModel> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments,
    List<String> keepExistingAttachmentIds,
  });

  Future<void> deletePost(String postId);

  Future<PostApiModel> toggleLike(String postId);
  Future<PostApiModel> toggleSave(String postId);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiClient api;
  PostsRemoteDataSourceImpl(this.api);

  Map<String, dynamic> _unwrapData(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body;
    }
    // fallback if some endpoint returns raw list (your feed method is inconsistent)
    return {'data': body};
  }

  @override
  Future<List<PostApiModel>> getAllPosts({int skip = 0, int limit = 10}) async {
    final res = await api.dio.get(
      ApiEndpoints.getAllPosts(),
      queryParameters: {'skip': skip, 'limit': limit},
    );

    final body = _unwrapData(res);
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map(PostApiModel.fromJson).toList();
  }

  @override
  Future<PostApiModel> getPostById(String id) async {
    final res = await api.dio.get(ApiEndpoints.getPostById(id));
    final body = _unwrapData(res);
    return PostApiModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<PostApiModel>> getDrafts() async {
    final res = await api.dio.get(ApiEndpoints.getDrafts());
    final body = _unwrapData(res);
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map(PostApiModel.fromJson).toList();
  }

  @override
  Future<List<PostApiModel>> getMyPosts() async {
    final res = await api.dio.get(ApiEndpoints.getMyPosts());
    final body = _unwrapData(res);
    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map(PostApiModel.fromJson).toList();
  }

  @override
  Future<PostApiModel> createPost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments = const [],
  }) async {
    final form = FormData();

    if (title != null) form.fields.add(MapEntry('title', title));
    if (description != null) form.fields.add(MapEntry('description', description));
    form.fields.add(MapEntry('content', content));

    // BACKEND EXPECTS req.body.draft === "true"
    form.fields.add(MapEntry('draft', asDraft ? 'true' : 'false'));

    for (final f in attachments) {
      form.files.add(
        MapEntry(
          'attachments',
          await MultipartFile.fromFile(f.path, filename: f.uri.pathSegments.last),
        ),
      );
    }

    final res = await api.dio.post(ApiEndpoints.createPost(), data: form);
    final body = _unwrapData(res);
    return PostApiModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<PostApiModel> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments = const [],
    List<String> keepExistingAttachmentIds = const [],
  }) async {
    final form = FormData();

    if (title != null) form.fields.add(MapEntry('title', title));
    if (description != null) form.fields.add(MapEntry('description', description));
    if (content != null) form.fields.add(MapEntry('content', content));

    // BACKEND EXPECTS req.body.draft === "true"
    form.fields.add(MapEntry('draft', asDraft ? 'true' : 'false'));

    // BACKEND expects existingAttachments (array or single)
    for (final id in keepExistingAttachmentIds) {
      form.fields.add(MapEntry('existingAttachments', id));
    }

    for (final f in newAttachments) {
      form.files.add(
        MapEntry(
          'attachments',
          await MultipartFile.fromFile(f.path, filename: f.uri.pathSegments.last),
        ),
      );
    }

    final res = await api.dio.put(ApiEndpoints.updatePost(postId), data: form);
    final body = _unwrapData(res);
    return PostApiModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePost(String postId) async {
    await api.dio.delete(ApiEndpoints.deletePost(postId));
  }

  @override
  Future<PostApiModel> toggleLike(String postId) async {
    final res = await api.dio.post(ApiEndpoints.toggleLike(postId));
    final body = _unwrapData(res);
    return PostApiModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<PostApiModel> toggleSave(String postId) async {
    final res = await api.dio.post(ApiEndpoints.toggleSave(postId));
    final body = _unwrapData(res);
    return PostApiModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}