import 'package:flutter/material.dart';

class BookListTile extends StatelessWidget {
  final String title;
  final String author;
  final String label;

  const BookListTile({
    super.key,
    required this.title,
    required this.author,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.pink),
        title: Text(title),
        subtitle: Text('$author • $label'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
