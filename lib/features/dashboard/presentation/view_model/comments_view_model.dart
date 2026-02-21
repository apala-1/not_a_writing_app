import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/comment_remotedatasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/comment_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/create_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/delete_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/get_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/domain/usecases/update_comments_usecase.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/comments_state.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_by_id_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';
import 'package:intl/intl.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/comment_entity.dart';
import 'package:not_a_writing_app/features/profile/domain/entities/profile_entity.dart';

class CommentWithProfile {
  final CommentEntity comment;
  final ProfileEntity? userProfile;

  CommentWithProfile({required this.comment, this.userProfile});

  String get userName => userProfile?.name ?? 'Unknown';
  String? get userPfpUrl => userProfile?.profilePicture;
  String get createdAtFormatted =>
      DateFormat('MMM d, yyyy • h:mm a').format(comment.createdAt);
}

// Provider for UserSessionService (make sure you already have this)
final userSessionProvider = Provider<UserSessionService>((ref) {
  return ref.read(userSessionServiceProvider);
});

// Comments ViewModel provider
final commentViewModelProvider =
    StateNotifierProvider<CommentViewModel, CommentState>((ref) {
  final userSession = ref.read(userSessionProvider);

  final repo = CommentRepositoryImpl(
    CommentRemoteDataSourceImpl(userSessionService: userSession),
  );

  return CommentViewModel(
    GetCommentsUseCase(repo),
    CreateCommentUseCase(repo),
    UpdateCommentUseCase(repo),
    DeleteCommentUseCase(repo),
  );
});

class CommentViewModel extends StateNotifier<CommentState> {
  final GetCommentsUseCase getComments;
  final CreateCommentUseCase createComment;
  final UpdateCommentUseCase updateComment;
  final DeleteCommentUseCase deleteComment;

  CommentViewModel(
    this.getComments,
    this.createComment,
    this.updateComment,
    this.deleteComment,
  ) : super(CommentState.initial());

  /// Load comments WITHOUT profiles
  Future<void> loadComments(String postId) async {
    state = state.copyWith(comments: const AsyncValue.loading());
    try {
      final result = await getComments(postId);

      // Convert CommentEntity -> CommentWithProfile (no userProfile yet)
      final commentsWithProfiles = result
          .map((c) => CommentWithProfile(comment: c, userProfile: null))
          .toList();

      state = state.copyWith(
        comments: AsyncValue.data(commentsWithProfiles),
        status: CommentStatus.loaded,
      );
    } catch (e, st) {
      state = state.copyWith(
        comments: AsyncValue.error(e, st),
        status: CommentStatus.error,
      );
    }
  }

  Future<void> add(String postId, String content) async {
    await createComment(postId, content);
    await loadComments(postId);
  }

  Future<void> update(String commentId, String content, String postId) async {
    await updateComment(commentId, content);
    await loadComments(postId);
  }

  Future<void> delete(String commentId, String postId) async {
    await deleteComment(commentId);
    await loadComments(postId);
  }

  Future<void> loadCommentsWithProfiles(String postId, WidgetRef ref) async {
  state = CommentState(comments: const AsyncValue.loading());
  try {
    // 1. Load all comments
    final comments = await getComments(postId);
    print("Comments: $comments");

    // 2. Prepare a local map of userId -> ProfileEntity
    final profiles = <String, ProfileEntity>{};

    // 3. Fetch profiles per comment without touching global ProfileViewmodel
    for (var comment in comments) {
      if (!profiles.containsKey(comment.userId)) {
        final result = await ref.read(getProfileByIdUsecaseProvider)(comment.userId);

result.fold(
  (failure) {
    profiles[comment.userId] = ProfileEntity(
      id: comment.userId,
      name: 'Unknown',
      email: '',
      profilePicture: '',
      occupation: '',
      bio: '',
      token: null,
      postsCount: 0,
    );
  },
  (data) {
    final profileData = data; // <-- extract 'data' here
    profiles[comment.userId] = ProfileEntity(
      id: profileData.id ?? comment.userId, // use 'id' field if API gives it
      name: profileData.name,
      email: profileData.email,
      profilePicture: profileData.profilePicture,
      occupation: profileData.occupation,
      bio: profileData.bio,
      token: profileData.token,
      postsCount: profileData.postsCount ?? 0,
    );
  },
);

      }
    }

    // 4. Combine comments + profiles
    final commentsWithProfiles = comments
        .map((c) => CommentWithProfile(
              comment: c,
              userProfile: profiles[c.userId],
            ))
        .toList();

    // 5. Update state
    state = state.copyWith(
      comments: AsyncValue.data(commentsWithProfiles),
      status: CommentStatus.loaded,
    );
  } catch (e, st) {
    state = state.copyWith(
      comments: AsyncValue.error(e, st),
      status: CommentStatus.error,
    );
  }
}
}