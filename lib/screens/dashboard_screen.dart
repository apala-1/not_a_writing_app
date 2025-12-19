import 'package:flutter/material.dart';
import 'package:not_a_writing_app/widgets/bottom_nav.dart';
import 'package:not_a_writing_app/widgets/custom_appbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar
      appBar: CustomAppBar(),

      // Main body
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

              // Streak card
              _buildStreakCard(),

              const SizedBox(height: 16),

              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(Icons.lightbulb, 'Prompt'),
                  _buildQuickAction(Icons.book, 'Reading'),
                  _buildQuickAction(Icons.edit, 'Writing'),
                ],
              ),

              const SizedBox(height: 24),

              // Progress section
              const Text(
                'Your Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildProgressCard('Finish reading "Once in a LifeTime"', 0.63),
              _buildProgressCard('Finish writing "Summer Vibes"', 0.24),

              const SizedBox(height: 24),

              // Discover section
              const Text(
                'Discover',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildPostCard(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // 🔥 Streak card
  Widget _buildStreakCard() {
    return Card(
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '🔥 4-Day Streak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You’re on fire! Keep going 💪'),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
              ),
              onPressed: () {},
              child: const Text('+ Start Writing'),
            ),
          ],
        ),
      ),
    );
  }

  // ⚡ Quick action buttons
  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.pink.shade100,
          child: Icon(icon, color: Colors.pink.shade700),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  // 📊 Progress card
  Widget _buildProgressCard(String title, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: Colors.pink.shade300,
              backgroundColor: Colors.pink.shade50,
            ),
            const SizedBox(height: 4),
            Text('Hooray!! You’ve completed ${(progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  // 🌍 Discover post
  Widget _buildPostCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Text('J')),
        title: const Text('John Doe • Recreational Writer'),
        subtitle: const Text(
          'Today at 6:48 AM\nOnce upon a midnight dreary...',
        ),
        isThreeLine: true,
      ),
    );
  }
}
