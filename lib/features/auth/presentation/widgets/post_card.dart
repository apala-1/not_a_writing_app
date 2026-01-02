import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final VoidCallback onTap;

  const PostCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Text('J')),
          title: const Text('John Doe • Recreational Writer'),
          subtitle: const Text(
            'Today at 6:48 AM\nOnce upon a midnight dreary...',
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
