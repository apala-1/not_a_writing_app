import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/comments_sheet.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/expandable_text.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/like_save_action_button.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/progress_card.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/quick_action_item.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:not_a_writing_app/features/posts/presentation/state/post_with_user_state.dart';
import 'package:not_a_writing_app/theme/colors.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

import 'book_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _shakeThreshold = 15.0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _startShakeDetection();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(dashboardViewModelProvider.notifier).fetchPosts();
    }
  }

  void _navigateTo(Widget screen) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );

  // If a new post was created, refresh feed
  if (result == true) {
    ref.read(dashboardViewModelProvider.notifier).refreshPosts();
  }
}

void _startShakeDetection() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      double acceleration =
    sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration > _shakeThreshold && !_isRefreshing) {
        _isRefreshing = true;

        // Showing Message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Refreshing feed...")),
        );

        ref.read(dashboardViewModelProvider.notifier).refreshPosts();
        Future.delayed(const Duration(seconds: 2), () {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final postsAsync = dashboardState.posts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi Apala 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Let’s write something meaningful today',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              StreakCard(
                onStartWriting: () => _navigateTo(const WriteScreen()),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionItem(icon: Icons.lightbulb_outline, label: 'Prompt', onTap: () {}),
                  QuickActionItem(icon: Icons.menu_book_outlined, label: 'Reading', onTap: () {}),
                  QuickActionItem(
                    icon: Icons.edit_outlined,
                    label: 'Writing',
                    onTap: () => _navigateTo(const WriteScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ProgressCard(
                title: 'Finish reading "Once in a Lifetime"',
                progress: 0.63,
                onTap: () => _navigateTo(const BookDetailScreen()),
              ),
              ProgressCard(
                title: 'Finish writing "Summer Vibes"',
                progress: 0.24,
                onTap: () => _navigateTo(const WriteScreen()),
              ),
              const SizedBox(height: 36),

              const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts found'));
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        return ref.read(dashboardViewModelProvider.notifier).hasMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final postWithUser = posts[index];
                      return _PostCard(postId: postWithUser.post.id);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final String postId;
  const _PostCard({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final postWithUser = dashboardState.posts.value!
        .firstWhere((p) => p.post.id == postId);

    final vm = ref.read(dashboardViewModelProvider.notifier);
    final post = postWithUser.post;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: post.attachments.map((attachment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(
                    "${ApiEndpoints.mediaServerUrl}${attachment.url}",
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              post.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ExpandableText(
              text: post.content,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    ActionButton(
      icon: Icons.thumb_up,
      label: post.likesCount.toString(),
      onTap: () => vm.toggleLike(post.id),
      color: postWithUser.isLiked ? Colors.blue : AppColors.textSecondary, // change
    ),
    ActionButton(
      icon: Icons.comment,
      label: post.commentsCount.toString(),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => CommentsSheet(postId: post.id),
        );
      },
    ),
    ActionButton(
      icon: Icons.share,
      label: post.sharesCount.toString(),
      onTap: () => vm.addShare(post.id),
    ),
    ActionButton(
      icon: Icons.bookmark,
      label: postWithUser.isSaved ? 'Saved' : 'Save',
      onTap: () => vm.toggleSave(post.id),
      color: postWithUser.isSaved ? Colors.blue : AppColors.textSecondary, // change
    ),
  ],
)
          ],
        ),
      ),
    );
  }
}
