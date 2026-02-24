import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/posts/presentation/state/post_with_user_state.dart';
import 'package:not_a_writing_app/features/profile/data/models/profile_api_model.dart';

class DashboardState {
  final AsyncValue<List<PostWithUserState>> posts; // <- use PostWithUserState
  final AsyncValue<ProfileApiModel?> profile;

  DashboardState({
    required this.posts,
    required this.profile,
  });

  DashboardState copyWith({
    AsyncValue<List<PostWithUserState>>? posts,
    AsyncValue<ProfileApiModel?>? profile,
  }) {
    return DashboardState(
      posts: posts ?? this.posts,
      profile: profile ?? this.profile,
    );
  }
}