import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/write_create_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/post_card.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/progress_card.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/quick_action_item.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:not_a_writing_app/theme/colors.dart';

import 'book_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
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

              PostCard(
                onTap: () => _navigateTo(const BookDetailScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
