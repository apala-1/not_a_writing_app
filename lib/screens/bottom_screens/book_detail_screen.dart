import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
    
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade200),
              onPressed: () {},
              child: const Text('Read'),
            ),
            const SizedBox(height: 8),
            const Text('John Doe • Recreational Writer'),
            const Row(children: [
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
            ]),
            const SizedBox(height: 16),
            const Text('About Work:\nLorem ipsum dolor sit amet...'),
            const SizedBox(height: 16),
            const Text('You may also like',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildSuggestion('BOOK TITLE'),
            _buildSuggestion('THE NOVEL'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(String title) {
    return Card(
      color: Colors.orange.shade100,
      child: ListTile(
        leading: const Icon(Icons.book),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
