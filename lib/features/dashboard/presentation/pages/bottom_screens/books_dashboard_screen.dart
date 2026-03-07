import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_create_wizard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_detail_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_args.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';

class BooksDashboardScreen extends ConsumerWidget {
  const BooksDashboardScreen({super.key});

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(booksDashboardVmProvider);
    final vm = ref.read(booksDashboardVmProvider.notifier);

    return Scaffold(
      backgroundColor: bgColor,
      // 1. Custom Gradient Floating Action Button
      floatingActionButton: _buildGradientFAB(context, vm),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(top: -100, left: -50, child: _buildBlob(300, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: -50, right: -50, child: _buildBlob(250, rosePrimary.withOpacity(0.1))),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator(color: orangePrimary))
                      : state.books.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.books.length,
                              itemBuilder: (_, i) => _buildBookCard(context, state.books[i], vm),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Library",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            "Manage your stories and drafts",
            style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, dynamic b, dynamic vm) {
    final isDraft = b.status.toString().toLowerCase() == 'draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: b.id))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Book Cover with status badge overlay
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(2, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(b.coverPhotoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: orangePrimary.withOpacity(0.1), child: const Icon(LucideIcons.book, color: orangePrimary))),
                        ),
                      ),
                      if (isDraft)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(8)),
                            child: const Text("DRAFT", style: TextStyle(color: Color(0xFF713F12), fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Book Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        _buildInfoRow(LucideIcons.layers, "${b.chapters.length} Chapters"),
                        const SizedBox(height: 4),
                        _buildInfoRow(b.visibility.toString().toLowerCase() == 'public' ? LucideIcons.globe : LucideIcons.lock, b.visibility.toString()),
                        const SizedBox(height: 12),
                        // Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: orangePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(b.status.toString().toUpperCase(), style: const TextStyle(color: orangePrimary, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  // Actions Menu
                  _buildPopupMenu(context, b, vm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context, dynamic b, dynamic vm) {
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.moveVertical, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) async {
        if (v == 'delete') await vm.onDelete(b.id);
        if (v == 'edit') {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => BookEditorScreen(args: BookEditorArgs.edit(existingBookId: b.id))));
          vm.load();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.penLine400, size: 18), SizedBox(width: 12), Text("Edit")])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent), SizedBox(width: 12), Text("Delete", style: TextStyle(color: Colors.redAccent))])),
      ],
    );
  }

  Widget _buildGradientFAB(BuildContext context, dynamic vm) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [orangePrimary, rosePrimary]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: rosePrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        onPressed: () async {
          final args = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BookCreateWizardScreen()));
          if (args != null) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => BookEditorScreen(args: args)));
            vm.load();
          }
        },
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text("Create Story", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bookOpen, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your library is empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text("Start your writing journey today!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}