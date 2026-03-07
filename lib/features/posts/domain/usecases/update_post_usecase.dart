import 'dart:io';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

import '../entities/post_entity.dart';

class UpdatePostUsecase {
  final PostsRepository repo;
  UpdatePostUsecase(this.repo);

  Future<PostEntity> call({
    required String postId,
    String? title,
    String? description,
    String? content,
    required bool asDraft,
    List<File> newAttachments = const [],
    List<String> keepExistingAttachmentIds = const [],
  }) {
    return repo.updatePost(
      postId: postId,
      title: title,
      description: description,
      content: content,
      asDraft: asDraft,
      newAttachments: newAttachments,
      keepExistingAttachmentIds: keepExistingAttachmentIds,
    );
  }
}