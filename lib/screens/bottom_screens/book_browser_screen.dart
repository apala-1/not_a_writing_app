import 'package:flutter/material.dart';

class BookBrowserScreen extends StatelessWidget {
  const BookBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // 📚 Genre tabs
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Horror', 'Mystery', 'Self-Help', 'Romance']
                    .map((genre) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(genre),
                            backgroundColor: Colors.pink.shade100,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 📖 Book List section
            _buildSectionHeader('Book List'),
            _buildBookTile('OTHER LONDON', 'M.V. STOTT', 'Book One'),
            _buildBookTile('WALK INTO THE SHADOW', 'Unknown', 'Book Two'),

            const SizedBox(height: 16),

            // 🌟 Most Popular section
            _buildSectionHeader('Most Popular'),
            _buildBookTile('BOOK TITLE', 'AUTHOR NAME', 'Book One'),
            _buildBookTile('THE NOVEL', 'AUTHOR NAME', 'Book Two'),
          ],
        ),
      ),

    
    );
  }

  // 🔖 Section header with "More >"
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text('More >')),
      ],
    );
  }

  // 📘 Book tile
  Widget _buildBookTile(String title, String author, String label) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.pink),
        title: Text(title),
        subtitle: Text('$author • $label'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
