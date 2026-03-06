import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/comments_sheet.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/expandable_text.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/like_save_action_button.dart';
import 'package:not_a_writing_app/features/posts/presentation/pages/write_create_screen.dart';
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
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final double _shakeThreshold = 20.0;
  bool _isRefreshing = false;

  // Modern Orange Rose Palette
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color softRose = Color(0xFFFFF1F2);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Refreshing feed..."),
            backgroundColor: primaryOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        ref.read(dashboardViewModelProvider.notifier).refreshPosts();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isRefreshing = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final postsAsync = dashboardState.posts;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryOrange,
          onRefresh: () async => ref.read(dashboardViewModelProvider.notifier).refreshPosts(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hi Apala 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to write some magic?',
                          style: TextStyle(
                            fontSize: 15,
                            color: textGray.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: softRose,
                        child: Icon(Icons.notifications_none_rounded, color: roseAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Streak Card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [primaryOrange, roseAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: roseAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: StreakCard(
                    onStartWriting: () => _navigateTo(const WriteScreen()),
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Actions
                const Text(
                  'Quick Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(Icons.auto_awesome_rounded, 'Prompt', Colors.amber),
                    _buildQuickAction(Icons.menu_book_rounded, 'Reading', Colors.blueAccent),
                    _buildQuickAction(
                      Icons.edit_note_rounded,
                      'Writing',
                      primaryOrange,
                      onTap: () => _navigateTo(const WriteScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Progress Section
                const Row(
                  children: [
                    Icon(Icons.insights_rounded, color: primaryOrange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Your Journey',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ProgressCard(
                  title: 'Finish "Once in a Lifetime"',
                  progress: 0.63,
                  onTap: () => _navigateTo(const BookDetailScreen()),
                ),
                const SizedBox(height: 12),
                ProgressCard(
                  title: 'Finish "Summer Vibes"',
                  progress: 0.24,
                  onTap: () => _navigateTo(const WriteScreen()),
                ),
                const SizedBox(height: 40),

                // Feed Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discover Stories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All', style: TextStyle(color: roseAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('No stories yet. Be the first to write!'),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: posts.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        if (index == posts.length) {
                          return ref.read(dashboardViewModelProvider.notifier).hasMore
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                                )
                              : const SizedBox(height: 40);
                        }

                        final postWithUser = posts[index];
                        return _PostCard(postId: postWithUser.post.id);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: primaryOrange),
                    ),
                  ),
                  error: (e, st) => Center(child: Text('Failed to load feed: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textDark),
          ),
        ],
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF7F00).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFFFF7F00)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Author Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('2h ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                ],
              ),
            ),

            // Image Content
            if (post.attachments.isNotEmpty)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: post.attachments.length,
                  itemBuilder: (context, i) => Image.network(
                    "${ApiEndpoints.mediaServerUrl}${post.attachments[i].url}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF64748B).withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ExpandableText(
                    text: post.content,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PostAction(
                    icon: postWithUser.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    label: post.likesCount.toString(),
                    color: postWithUser.isLiked ? Colors.red : Colors.grey[600]!,
                    onTap: () => vm.toggleLike(post.id),
                  ),
                  _PostAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: post.commentsCount.toString(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommentsSheet(postId: post.id),
                      );
                    },
                  ),
                  _PostAction(
                    icon: Icons.share_outlined,
                    label: post.sharesCount.toString(),
                    onTap: () => vm.addShare(post.id),
                  ),
                  _PostAction(
                    icon: postWithUser.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    label: postWithUser.isSaved ? 'Saved' : 'Save',
                    color: postWithUser.isSaved ? Colors.orange : Colors.grey[600]!,
                    onTap: () => vm.toggleSave(post.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF64748B),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}