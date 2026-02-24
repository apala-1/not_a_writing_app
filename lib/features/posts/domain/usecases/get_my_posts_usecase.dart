import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/posts/data/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';

// Usecase provider
final getMyPostsUsecaseProvider = Provider<GetMyPostsUsecase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return GetMyPostsUsecase(repo);
});

final myPostsProvider = FutureProvider<List<PostEntity>>((ref) async {
  final usecase = ref.read(getMyPostsUsecaseProvider);
  final result = await usecase(ref.read(userSessionServiceProvider).getUserId()!, skip: 0, limit: 20);

  return result;
});

class GetMyPostsUsecase {
  final IPostRepository repository;

  GetMyPostsUsecase(this.repository);

  Future<List<PostEntity>> call(String userId, {int skip = 0, int limit = 10}) {
    return repository.getMyPosts(userId,skip: skip, limit: limit);
  }
}