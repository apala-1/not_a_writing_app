import 'dart:io';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remote;
  PostsRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getAllPosts({int skip = 0, int limit = 10}) async {
    final models = await remote.getAllPosts(skip: skip, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PostEntity> getPostById(String id) async {
    final m = await remote.getPostById(id);
    return m.toEntity();
  }

  @override
  Future<List<PostEntity>> getDrafts() async {
    final models = await remote.getDrafts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PostEntity>> getMyPosts() async {
    final models = await remote.getMyPosts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PostEntity> createPost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments = const [],
  }) async {
    final m = await remote.createPost(
      title: title,
      description: description,
      content: content,
      asDraft: asDraft,
      attachments: attachments,
    );
    return m.toEntity();
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments = const [],
    List<String> keepExistingAttachmentIds = const [],
  }) async {
    final m = await remote.updatePost(
      postId: postId,
      title: title,
      description: description,
      content: content,
      asDraft: asDraft,
      newAttachments: newAttachments,
      keepExistingAttachmentIds: keepExistingAttachmentIds,
    );
    return m.toEntity();
  }

  @override
  Future<void> deletePost(String postId) => remote.deletePost(postId);

  @override
  Future<PostEntity> toggleLike(String postId) async {
    final m = await remote.toggleLike(postId);
    return m.toEntity();
  }

  @override
  Future<PostEntity> toggleSave(String postId) async {
    final m = await remote.toggleSave(postId);
    return m.toEntity();
  }
}