import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback onTap;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Hooray!! You’ve completed ${(progress * 100).toInt()}%',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
