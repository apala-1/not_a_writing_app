import 'dart:io';
import '../entities/post_entity.dart';

abstract class PostsRepository {
  Future<List<PostEntity>> getAllPosts({int skip, int limit});
  Future<PostEntity> getPostById(String id);

  Future<List<PostEntity>> getDrafts();
  Future<List<PostEntity>> getMyPosts();

  Future<PostEntity> createPost({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments,
  });

  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments,
    List<String> keepExistingAttachmentIds,
  });

  Future<void> deletePost(String postId);

  Future<PostEntity> toggleLike(String postId);
  Future<PostEntity> toggleSave(String postId);
}