import 'package:flutter/material.dart';

class WriteScreen extends StatelessWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Title, 22 November 10:05 | 0 characters'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.format_bold),
                Icon(Icons.format_size),
                Icon(Icons.image),
                Icon(Icons.gif),
                Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200),
              onPressed: () {},
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
