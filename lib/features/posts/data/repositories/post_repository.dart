import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/post_datasource.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  final remote = ref.read(postRemoteDatasourceProvider);
  return PostRepositoryImpl(remoteDatasource: remote);
});

class PostRepositoryImpl implements IPostRepository {
  final IPostRemoteDatasource _remoteDatasource;

  PostRepositoryImpl({required IPostRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<PostEntity> createPost({
    required String title,
    required String description,
    required String content,
    required bool isDraft,
    List<File>? attachments,
  }) {
    return _remoteDatasource.createPost(
      title: title,
      description: description,
      content: content,
      isDraft: isDraft,
      attachments: attachments,
    );
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    bool? isDraft,
    List<File>? attachments,
  }) {
    return _remoteDatasource.updatePost(
      postId: postId,
      title: title,
      description: description,
      content: content,
      isDraft: isDraft,
      attachments: attachments,
    );
  }

  @override
  Future<void> addShare(String postId) {
    return _remoteDatasource.addShare(postId);
  }

  @override
  Future<void> addView(String postId) {
    return _remoteDatasource.addView(postId);
  }
  
  @override
   Future<List<PostEntity>> getAllPosts({
    int skip = 0,
    int limit = 10,
  }) {
    return _remoteDatasource.getAllPosts(
      skip: skip,
      limit: limit,
    );
  }
  
  @override
  Future<List<PostEntity>> getDrafts() {
    // TODO: implement getDrafts
    throw UnimplementedError();
  }
  
  @override
  Future<List<PostEntity>> getFeed({String? lastCreatedAt, int limit = 10}) {
    // TODO: implement getFeed
    throw UnimplementedError();
  }
  
   @override
  Future<PostEntity> getPostById(String postId) {
    return _remoteDatasource.getPostById(postId);
  }

  @override
  Future<List<PostEntity>> getRankedFeed({
    int skip = 0,
    int limit = 10,
  }) {
    return _remoteDatasource.getRankedFeed(
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<void> toggleLike(String postId) {
    return _remoteDatasource.toggleLike(postId);
  }

  @override
  Future<void> toggleSave(String postId) {
    return _remoteDatasource.toggleSave(postId);
  }
}
