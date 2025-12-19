import 'package:flutter/material.dart';

class BookSuggestionTile extends StatelessWidget {
  final String title;

  const BookSuggestionTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
      child: ListTile(
        leading: const Icon(Icons.book),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
