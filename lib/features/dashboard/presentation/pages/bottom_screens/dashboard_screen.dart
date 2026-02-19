import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/post_card.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/progress_card.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/quick_action_item.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:not_a_writing_app/theme/colors.dart';

import 'book_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(dashboardViewModelProvider.notifier).fetchPosts();
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
final postsAsync = dashboardState.posts;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Greeting
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

              // 🔥 Streak Card
              StreakCard(
                onStartWriting: () => _navigateTo(const WriteScreen()),
              ),

              const SizedBox(height: 28),

              // ⚡ Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionItem(
                    icon: Icons.lightbulb_outline,
                    label: 'Prompt',
                    onTap: () {}
                  ),
                  QuickActionItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Reading',
                    onTap: () {}
                  ),
                  QuickActionItem(
                    icon: Icons.edit_outlined,
                    label: 'Writing',
                    onTap: () => _navigateTo(const WriteScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // 📈 Progress Section
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

              // 🌍 Discover Section
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
                    return const Center(
                      child: Text('No posts found'),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        // show loader if more posts are loading
                        return ref.read(dashboardViewModelProvider.notifier).hasMore
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final post = posts[index];
                      return _PostCard(post: post);
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
  final PostEntity post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(dashboardViewModelProvider.notifier);

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

            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              post.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Content (short preview)
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Like, Comment, Share, Save buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.thumb_up,
                  label: post.likesCount.toString(),
                  onTap: () => vm.toggleLike(post.id),
                ),
                _ActionButton(
                  icon: Icons.comment,
                  label: post.commentsCount.toString(),
                  onTap: () {}, // TODO: Navigate to post comments
                ),
                _ActionButton(
                  icon: Icons.share,
                  label: post.sharesCount.toString(),
                  onTap: () => vm.addShare(post.id),
                ),
                _ActionButton(
                  icon: Icons.bookmark,
                  label: post.savesCount.toString(),
                  onTap: () => vm.toggleSave(post.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}