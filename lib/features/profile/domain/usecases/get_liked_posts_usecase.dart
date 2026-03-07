import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/repositories/profile_repository.dart';

class GetLikedPostsUsecase {
  final IProfileRepository repo;
  GetLikedPostsUsecase(this.repo);
  Future<List<PostEntity>> call() => repo.getLikedPosts();
}