import 'package:flutter/material.dart';
import 'package:not_a_writing_app/widgets/post_card.dart';
import 'package:not_a_writing_app/widgets/progress_card.dart';
import 'package:not_a_writing_app/widgets/quick_action_item.dart';
import 'package:not_a_writing_app/widgets/streak_card.dart';
import 'book_detail_screen.dart';
import '../write_create_screen.dart';
import '../post_setup_screen.dart';

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
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi Apala 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              StreakCard(
                onStartWriting: () => _navigateTo(const WriteScreen()),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionItem(
                    icon: Icons.lightbulb,
                    label: 'Prompt',
                    onTap: () => _navigateTo(const PostSetupScreen()),
                  ),
                  QuickActionItem(
                    icon: Icons.book,
                    label: 'Reading',
                    onTap: () => _navigateTo(const BookDetailScreen()),
                  ),
                  QuickActionItem(
                    icon: Icons.edit,
                    label: 'Writing',
                    onTap: () => _navigateTo(const WriteScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Your Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              ProgressCard(
                title: 'Finish reading "Once in a LifeTime"',
                progress: 0.63,
                onTap: () => _navigateTo(const BookDetailScreen()),
              ),

              ProgressCard(
                title: 'Finish writing "Summer Vibes"',
                progress: 0.24,
                onTap: () => _navigateTo(const WriteScreen()),
              ),

              const SizedBox(height: 24),
              const Text(
                'Discover',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
