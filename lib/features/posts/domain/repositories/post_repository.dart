import 'dart:io';
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

  Future<List<Post>> getDrafts();
  Future<List<Post>> getAllPosts({int skip = 0, int limit = 10});
  Future<Post> getPostById(String postId);

  Future<void> toggleLike(String postId);
  Future<void> toggleSave(String postId);
  Future<void> addShare(String postId);
  Future<void> addView(String postId);

  Future<List<Post>> getFeed({String? lastCreatedAt, int limit = 10});
  Future<List<Post>> getRankedFeed({int skip = 0, int limit = 10});
}