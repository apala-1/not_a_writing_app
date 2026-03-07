import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/comment_remotedatasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/delete_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/update_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/comments_state.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/comments_providers.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_comments_by_post_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/reply_to_comment_usecase.dart';

final getCommentsByPostUsecaseProvider = Provider((ref) {
  return GetCommentsByPostUsecase(ref.read(commentsRepoProvider));
});

final createCommentUsecaseProvider = Provider((ref) {
  return CreateCommentUsecase(ref.read(commentsRepoProvider));
});

final replyToCommentUsecaseProvider = Provider((ref) {
  return ReplyToCommentUsecase(ref.read(commentsRepoProvider));
});

final updateCommentUsecaseProvider = Provider((ref) {
  return UpdateCommentUsecase(ref.read(commentsRepoProvider));
});

final deleteCommentUsecaseProvider = Provider((ref) {
  return DeleteCommentUsecase(ref.read(commentsRepoProvider));
});

final commentsRemoteProvider = Provider<CommentsRemoteDataSource>((ref) {
  final api = ref.read(apiClientProvider);
  return CommentsRemoteDataSourceImpl(api);
});

// Repo
final commentsRepoProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepositoryImpl(ref.read(commentsRemoteProvider));
});

// VM (family by postId)
final commentsVmProvider =
    StateNotifierProvider.family<CommentsVm, CommentsState, String>((ref, postId) {
  return CommentsVm(repo: ref.read(commentsRepoProvider), postId: postId)..load();
});