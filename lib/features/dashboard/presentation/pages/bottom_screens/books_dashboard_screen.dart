import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_create_wizard_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_detail_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_args.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/book_editor_screen.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';


class BooksDashboardScreen extends ConsumerWidget {
  const BooksDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(booksDashboardVmProvider);
    final vm = ref.read(booksDashboardVmProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Wizard -> returns a draft "BookEditorArgs"
          final args = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookCreateWizardScreen()),
          );
          if (args != null && context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookEditorScreen(args: args)),
            );
            vm.load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: state.books.length,
              itemBuilder: (_, i) {
                final b = state.books[i];
                return ListTile(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: b.id)),
  );
},
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(b.coverPhotoUrl, width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text(b.title),
                  subtitle: Text('${b.chapters.length} chapters • ${b.status} • ${b.visibility}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'delete') await vm.onDelete(b.id);
                      if (v == 'edit' && context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookEditorScreen(
                              args: BookEditorArgs.edit(existingBookId: b.id),
                            ),
                          ),
                        );
                        vm.load();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}