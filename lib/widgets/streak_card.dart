import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final VoidCallback onStartWriting;

  const StreakCard({super.key, required this.onStartWriting});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
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
                backgroundColor: Colors.deepOrange.shade200,
              ),
              onPressed: onStartWriting,
              child: const Text('+ Start Writing'),
            ),
          ],
        ),
      ),
    );
  }
}
