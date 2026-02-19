import 'dart:io';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

abstract class IPostRemoteDatasource {
  // Create / Update
  Future<PostEntity> createPost({
    required String title,
    required String description,
    required String content,
    required bool isDraft,
    List<File>? attachments,
  });

  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    bool? isDraft,
    List<File>? attachments,
  });

  // Basic Actions
  Future<void> addShare(String postId);
  Future<void> addView(String postId);
  Future<void> toggleLike(String postId);
  Future<void> toggleSave(String postId);

  // Fetching Posts
  Future<List<PostEntity>> getAllPosts({int skip = 0, int limit = 10});
  Future<List<PostEntity>> getDrafts();
  Future<List<PostEntity>> getFeed({String? lastCreatedAt, int limit = 10});
  Future<List<PostEntity>> getRankedFeed({int skip = 0, int limit = 10});
  Future<PostEntity> getPostById(String postId);
}