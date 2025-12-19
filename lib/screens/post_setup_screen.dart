import 'package:flutter/material.dart';

class PostSetupScreen extends StatelessWidget {
  const PostSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('Finalize Your Post'),
        backgroundColor: Colors.deepOrange.shade200,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField(context, 'Add cover photo', Icons.image),
            _buildField(context, 'Choose Category', Icons.category),
            _buildField(context, 'Add Title', Icons.title),
            _buildField(context, 'Add Tags', Icons.tag),

            const SizedBox(height: 8),
            const Text(
              'Tags are separated by commas.',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Handle post submission
              },
              child: const Text(
                'Skip, and Post',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'You can always edit later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, IconData icon) {
    return Card(
      color: Colors.orange.shade100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange.shade300),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle navigation or input for this field
        },
      ),
    );
  }
}
