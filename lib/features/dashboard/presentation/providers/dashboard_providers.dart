import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/dashboard_cache_providers.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:not_a_writing_app/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:not_a_writing_app/features/posts/data/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/repositories/post_repository.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/toggle_save_usecase.dart';
import 'package:not_a_writing_app/features/posts/domain/usecases/update_post_usecase.dart';

// you already have apiClientProvider in your ApiClient file
import 'package:not_a_writing_app/core/api/api_client.dart' show apiClientProvider;

final postsRemoteDsProvider = Provider<PostsRemoteDataSource>((ref) {
  final api = ref.read(apiClientProvider);
  return PostsRemoteDataSourceImpl(api);
});

final postsRepoProvider = Provider<PostsRepository>((ref) {
  return PostsRepositoryImpl(ref.read(postsRemoteDsProvider));
});

final getAllPostsUcProvider = Provider((ref) => GetAllPostsUsecase(ref.read(postsRepoProvider)));
final createPostUcProvider = Provider((ref) => CreatePostUsecase(ref.read(postsRepoProvider)));
final updatePostUcProvider = Provider((ref) => UpdatePostUsecase(ref.read(postsRepoProvider)));
final deletePostUcProvider = Provider((ref) => DeletePostUsecase(ref.read(postsRepoProvider)));
final toggleLikeUcProvider = Provider((ref) => ToggleLikeUsecase(ref.read(postsRepoProvider)));
final toggleSaveUcProvider = Provider((ref) => ToggleSaveUsecase(ref.read(postsRepoProvider)));

final dashboardVmProvider = StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(
    getAllPosts: ref.read(getAllPostsUcProvider),
    createPost: ref.read(createPostUcProvider),
    updatePost: ref.read(updatePostUcProvider),
    deletePost: ref.read(deletePostUcProvider),
    toggleLike: ref.read(toggleLikeUcProvider),
    toggleSave: ref.read(toggleSaveUcProvider),
    cache: ref.read(dashboardFeedCacheProvider),
  )..refresh();
});