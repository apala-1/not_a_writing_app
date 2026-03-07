import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/mappers/posts_to_chapters.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:not_a_writing_app/features/posts/presentation/providers/posts_providers.dart'; // your posts repo/usecase providers
import 'book_editor_args.dart';

class BookCreateWizardScreen extends ConsumerStatefulWidget {
  const BookCreateWizardScreen({super.key});

  @override
  ConsumerState<BookCreateWizardScreen> createState() => _BookCreateWizardScreenState();
}

class _BookCreateWizardScreenState extends ConsumerState<BookCreateWizardScreen> {
  final selected = <String>{}; // postIds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Book')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Create from scratch'),
            subtitle: const Text('Write chapters yourself'),
            trailing: const Icon(Icons.chevron_right),
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
          const Divider(),
          const SizedBox(height: 8),
          const Text('Or select posts to use as chapters', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Fetch my posts for selection
          FutureBuilder<List<PostEntity>>(
            future: ref.read(getMyPostsUsecaseProvider)(), // you need a usecase/provider for my-posts
            builder: (context, snap) {
              if (!snap.hasData) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
              final posts = snap.data!;
              if (posts.isEmpty) return const Text('No posts found.');

              return Column(
                children: [
                  for (final p in posts)
                    CheckboxListTile(
                      value: selected.contains(p.id),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) selected.add(p.id);
                          if (v == false) selected.remove(p.id);
                        });
                      },
                      title: Text((p.title ?? '').isNotEmpty ? p.title! : (p.content ?? 'Untitled').trim()),
                      subtitle: Text('${p.attachments.length} attachments'),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () {
                            final chosen = posts.where((p) => selected.contains(p.id)).toList();
                            final chapters = PostsToChaptersMapper.map(chosen);
                            Navigator.pop(context, BookEditorArgs.create(initialChapters: chapters));
                          },
                    child: Text('Next (${selected.length} posts)'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}