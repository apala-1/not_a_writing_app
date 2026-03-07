import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/data/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_my_posts_usecase.dart';

// 1) Remote datasource provider
final postsRemoteDataSourceProvider = Provider<PostsRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PostsRemoteDataSourceImpl(apiClient);
});

// 2) Repository provider (THIS is what you asked for)
final postRepositoryProvider = Provider<PostsRepository>((ref) {
  final remote = ref.read(postsRemoteDataSourceProvider);
  return PostsRepositoryImpl(remote);
});

final getMyPostsUsecaseProvider = Provider<GetMyPostsUsecase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return GetMyPostsUsecase(repo);
});