import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/mappers/posts_to_chapters.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/presentation/providers/posts_providers.dart';
import 'book_editor_args.dart';

class BookCreateWizardScreen extends ConsumerStatefulWidget {
  const BookCreateWizardScreen({super.key});

  @override
  ConsumerState<BookCreateWizardScreen> createState() => _BookCreateWizardScreenState();
}

class _BookCreateWizardScreenState extends ConsumerState<BookCreateWizardScreen> {
  final selected = <String>{}; // postIds

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Start Your Story',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -50, right: -50, child: _buildBlob(200, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: -100, left: -50, child: _buildBlob(300, rosePrimary.withOpacity(0.1))),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildHeader("How would you like to start?"),
                const SizedBox(height: 20),

                /// 1. Create from Scratch Card
                _buildOptionCard(
                  title: "Create from scratch",
                  subtitle: "Write fresh chapters and build your world from the ground up.",
                  icon: LucideIcons.penLine400,
                  onTap: () {
                    final initial = <BookChapterEntity>[
                      const BookChapterEntity(
                        title: 'Chapter 1',
                        content: [BookContentItemEntity(type: 'text', value: '')],
                      )
                    ];
                    Navigator.pop(context, BookEditorArgs.create(initialChapters: initial));
                  },
                ),

                const SizedBox(height: 32),
                _buildHeader("Convert existing content"),
                const SizedBox(height: 12),
                Text(
                  "Select one or more of your posts to automatically transform them into book chapters.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),

                /// 2. Post Selection Section
                _buildPostSelectionArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildOptionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [orangePrimary, rosePrimary]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostSelectionArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: FutureBuilder<List<PostEntity>>(
        future: ref.read(getMyPostsUsecaseProvider)(),
        builder: (context, snap) {
          if (!snap.hasData) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: orangePrimary)));
          final posts = snap.data!;
          if (posts.isEmpty) return _buildEmptyPostsState();

          return Column(
            children: [
              ...posts.map((p) => _buildPostItem(p)),
              const SizedBox(height: 20),
              _buildNextButton(posts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostItem(PostEntity p) {
    final isSelected = selected.contains(p.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? orangePrimary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CheckboxListTile(
        activeColor: orangePrimary,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        value: isSelected,
        onChanged: (v) {
          setState(() {
            if (v == true) selected.add(p.id);
            if (v == false) selected.remove(p.id);
          });
        },
        title: Text(
          (p.title ?? '').isNotEmpty ? p.title! : (p.content ?? 'Untitled').trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${p.attachments.length} attachments',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildNextButton(List<PostEntity> posts) {
    final isEnabled = selected.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled ? const LinearGradient(colors: [orangePrimary, rosePrimary]) : null,
        color: isEnabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled ? [BoxShadow(color: rosePrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: !isEnabled ? null : () {
          final chosen = posts.where((p) => selected.contains(p.id)).toList();
          final chapters = PostsToChaptersMapper.map(chosen);
          Navigator.pop(context, BookEditorArgs.create(initialChapters: chapters));
        },
        child: Text(
          'Next (${selected.length} posts)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)));
  }

  Widget _buildEmptyPostsState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(LucideIcons.fileX, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("No posts found", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}