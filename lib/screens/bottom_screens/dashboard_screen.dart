import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import '../write_create_screen.dart';
import '../post_setup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _selectedIndex = 0;

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
              const Text('Hi Apala 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildStreakCard(),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(Icons.lightbulb, 'Prompt',
                      () => _navigateTo(const PostSetupScreen())),
                  _buildQuickAction(Icons.book, 'Reading',
                      () => _navigateTo(const BookDetailScreen())),
                  _buildQuickAction(Icons.edit, 'Writing',
                      () => _navigateTo(const WriteScreen())),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Your Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildProgressCard('Finish reading "Once in a LifeTime"', 0.63,
                  () => _navigateTo(const BookDetailScreen())),
              _buildProgressCard('Finish writing "Summer Vibes"', 0.24,
                  () => _navigateTo(const WriteScreen())),

              const SizedBox(height: 24),
              const Text('Discover',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildPostCard(() => _navigateTo(const BookDetailScreen())),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStreakCard() {
    return Card(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('🔥 4-Day Streak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You’re on fire! Keep going 💪'),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200),
              onPressed: () => _navigateTo(const WriteScreen()),
              child: const Text('+ Start Writing'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange.shade100,
            child: Icon(icon, color: Colors.deepOrange.shade300),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      String title, double progress, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: Colors.deepOrange.shade200,
                backgroundColor: Colors.orange.shade50,
              ),
              const SizedBox(height: 4),
              Text('Hooray!! You’ve completed ${(progress * 100).toInt()}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Text('J')),
          title: const Text('John Doe • Recreational Writer'),
          subtitle: const Text(
              'Today at 6:48 AM\nOnce upon a midnight dreary...'),
          isThreeLine: true,
        ),
      ),
    );
  }
}