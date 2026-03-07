import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/liked_saved_posts_state.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/liked_saved_posts_viewmodel.dart';

// from profile providers:
import 'package:not_a_writing_app/features/profile/presentation/providers/profile_cache_providers.dart'
    show getLikedPostsUcProvider, getSavedPostsUcProvider;

// from dashboard providers:
import 'package:not_a_writing_app/features/dashboard/presentation/providers/dashboard_providers.dart'
    show toggleLikeUcProvider, toggleSaveUcProvider;

final likedSavedPostsVmProvider =
    StateNotifierProvider<LikedSavedPostsViewModel, LikedSavedPostsState>((ref) {
  final vm = LikedSavedPostsViewModel(
    getLiked: ref.read(getLikedPostsUcProvider),
    getSaved: ref.read(getSavedPostsUcProvider),
    toggleLike: ref.read(toggleLikeUcProvider),
    toggleSave: ref.read(toggleSaveUcProvider),
  );

  vm.load(tab: LikedSavedTab.liked);
  return vm;
});