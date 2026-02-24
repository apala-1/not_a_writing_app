import 'dart:core';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:not_a_writing_app/core/error/failures.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

abstract class IPostRepository {
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

  Future<List<PostEntity>> getDrafts();
  Future<List<PostEntity>> getAllPosts({int skip = 0, int limit = 10});
  Future<PostEntity> getPostById(String postId);
  Future<List<PostEntity>> getMyPosts(String userId, {int skip = 0, int limit = 10});
  Future<void> toggleLike(String postId);
  Future<void> toggleSave(String postId);
  Future<void> addShare(String postId);
  Future<void> addView(String postId);

  Future<List<PostEntity>> getFeed({String? lastCreatedAt, int limit = 10});
  Future<List<PostEntity>> getRankedFeed({int skip = 0, int limit = 10});
}