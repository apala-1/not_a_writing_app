import 'dart:io';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

abstract class IPostRepository {
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

class PostRepositoryImpl implements IPostRepository {
  final IPostRemoteDatasource _remoteDatasource;

  PostRepositoryImpl({required IPostRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<Post> createPost({
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
  Future<Post> updatePost({
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
}
