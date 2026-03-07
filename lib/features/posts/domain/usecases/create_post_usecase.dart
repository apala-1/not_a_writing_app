import 'dart:io';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

import '../entities/post_entity.dart';

class CreatePostUsecase {
  final PostsRepository repo;
  CreatePostUsecase(this.repo);

  Future<PostEntity> call({
    String? title,
    String? description,
    required String content,
    required bool asDraft,
    List<File> attachments = const [],
  }) {
    return repo.createPost(
      title: title,
      description: description,
      content: content,
      asDraft: asDraft,
      attachments: attachments,
    );
  }
}