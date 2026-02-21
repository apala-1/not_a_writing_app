import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';

final getWholeCommentUsecaseProvider = Provider<GetWholeCommentUsecase>((ref) {
  final repository = ref.read(commentRepositoryProvider);
  return GetWholeCommentUsecase(repository);
});

class GetWholeCommentUsecase {
  final CommentRepository repository;

  GetWholeCommentUsecase(this.repository);

  Future<List<CommentEntity>> call(String userId) {
    return repository.getWholeCommentWithProfile(userId);
  }
}