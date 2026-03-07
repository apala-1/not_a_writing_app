import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/book_entity.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/books_providers.dart';
import 'book_editor_args.dart';

class BookEditorScreen extends ConsumerStatefulWidget {
  final BookEditorArgs args;
  const BookEditorScreen({super.key, required this.args});

  @override
  ConsumerState<BookEditorScreen> createState() => _BookEditorScreenState();
}

class _BookEditorScreenState extends ConsumerState<BookEditorScreen> {
  final _picker = ImagePicker();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String visibility = 'private';
  bool draft = true;

  File? coverFile;
  List<BookChapterEntity> chapters = [];

  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();

    if (widget.args is CreateBookArgs) {
      chapters = List.of((widget.args as CreateBookArgs).initialChapters);
    } else {
      // For edit, load book by id (simple)
      _loadForEdit();
    }
  }

  String? existingCoverUrl; // ✅ add

  Future<void> _loadForEdit() async {
    setState(() => loading = true);
    try {
      final id = (widget.args as EditBookArgs).existingBookId;
      final repo = ref.read(booksRepositoryProvider);
      final book = await repo.getBookById(id);

      titleCtrl.text = book.title;
      descCtrl.text = book.description;
      visibility = book.visibility;
      draft = book.status == 'draft';
      chapters = book.chapters;

      existingCoverUrl = book.coverPhotoUrl; // ✅ set

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Future<void> _pickCover() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    setState(() => coverFile = File(x.path));
  }

  void _addChapter() {
    setState(() {
      chapters = [
        ...chapters,
        BookChapterEntity(
          title: 'Chapter ${chapters.length + 1}',
          content: const [BookContentItemEntity(type: 'text', value: '')],
        ),
      ];
    });
  }

  void _removeChapter(int index) {
    setState(() {
      chapters = [...chapters]..removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (chapters.isEmpty) {
        throw Exception('A book must have at least one chapter');
      }

      final title = titleCtrl.text.trim();
      final desc = descCtrl.text.trim();
      if (title.isEmpty || desc.isEmpty) throw Exception('Title and description are required');

      if (widget.args is CreateBookArgs) {
        if (coverFile == null) throw Exception('Cover photo is required');
        final uc = ref.read(createBookUcProvider);
        await uc(
          title: title,
          description: desc,
          visibility: visibility,
          asDraft: draft,
          chapters: chapters,
          coverPhotoFile: coverFile!,
        );
      } else {
        final uc = ref.read(updateBookUcProvider);
        await uc(
          bookId: (widget.args as EditBookArgs).existingBookId,
          title: title,
          description: desc,
          visibility: visibility,
          asDraft: draft,
          chapters: chapters,
          coverPhotoFile: coverFile, // optional
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && (widget.args is EditBookArgs) && chapters.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args is CreateBookArgs ? 'Create Book' : 'Edit Book'),
        actions: [
          TextButton(
            onPressed: loading ? null : _save,
            child: loading ? const Text('Saving...') : const Text('Save'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null)
            MaterialBanner(
              content: Text(error!),
              actions: [TextButton(onPressed: () => setState(() => error = null), child: const Text('Dismiss'))],
            ),
         Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 90,
        height: 120,
        child: coverFile != null
            ? Image.file(coverFile!, fit: BoxFit.cover)
            : (existingCoverUrl != null
                ? Image.network(existingCoverUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image),
                  )),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: loading ? null : _pickCover,
            icon: const Icon(Icons.image),
            label: Text(coverFile == null ? 'Pick cover' : 'Change cover'),
          ),
          const SizedBox(height: 6),
          Text(
            coverFile?.path.split('/').last ??
                (existingCoverUrl != null ? 'Current cover loaded' : 'Cover required'),
          )
        ],
      ),
    )
  ],
),
          const SizedBox(height: 12),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: visibility,
            items: const [
              DropdownMenuItem(value: 'private', child: Text('Private')),
              DropdownMenuItem(value: 'public', child: Text('Public')),
              DropdownMenuItem(value: 'link', child: Text('Link')),
            ],
            onChanged: loading ? null : (v) => setState(() => visibility = v ?? 'private'),
            decoration: const InputDecoration(labelText: 'Visibility'),
          ),
          SwitchListTile(
            value: draft,
            onChanged: loading ? null : (v) => setState(() => draft = v),
            title: const Text('Save as draft'),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Text('Chapters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: loading ? null : _addChapter,
                icon: const Icon(Icons.add),
                label: const Text('Add chapter'),
              )
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: chapters.length,
  itemBuilder: (_, i) => _ChapterEditor(
    key: ValueKey('chapter-$i'),
    index: i,
    chapter: chapters[i],
    onChanged: (updated) {
      setState(() {
        chapters = [...chapters]..[i] = updated;
      });
    },
    onRemove: chapters.length <= 1 ? null : () => _removeChapter(i),
    pickAndUploadImage: () async {
      final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (x == null) return null;

      final file = File(x.path);

      final repo = ref.read(booksRepositoryProvider);

      // NOTE: this requires you to implement uploadChapterImage in repo + backend endpoint
      final url = await repo.uploadChapterImage(file);
      return url;
    },
  ),
),
      ]));
  }
}

class _ChapterEditor extends StatefulWidget {
  final int index;
  final BookChapterEntity chapter;
  final ValueChanged<BookChapterEntity> onChanged;
  final VoidCallback? onRemove;
  final Future<String?> Function() pickAndUploadImage;

  const _ChapterEditor({
    super.key,
    required this.index,
    required this.chapter,
    required this.onChanged,
    required this.onRemove,
    required this.pickAndUploadImage,
  });

  @override
  State<_ChapterEditor> createState() => _ChapterEditorState();
}

class _ChapterEditorState extends State<_ChapterEditor> {
  late final TextEditingController titleCtrl;
  late final TextEditingController contentCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.chapter.title);

    final textItem = widget.chapter.content.firstWhere(
      (c) => c.type == 'text',
      orElse: () => const BookContentItemEntity(type: 'text', value: ''),
    );
    contentCtrl = TextEditingController(text: textItem.value);
  }

  @override
  void didUpdateWidget(covariant _ChapterEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If parent replaces chapter object, update controllers only if needed
    if (oldWidget.chapter.title != widget.chapter.title && titleCtrl.text != widget.chapter.title) {
      titleCtrl.text = widget.chapter.title;
    }

    final newTextItem = widget.chapter.content.firstWhere(
      (c) => c.type == 'text',
      orElse: () => const BookContentItemEntity(type: 'text', value: ''),
    );

    if (oldWidget.chapter != widget.chapter && contentCtrl.text != newTextItem.value) {
      contentCtrl.text = newTextItem.value;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final chapter = widget.chapter;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Chapter ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (widget.onRemove != null)
                IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline)),
            ],
          ),

          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Chapter title'),
            onChanged: (v) {
              widget.onChanged(BookChapterEntity(title: v, content: chapter.content));
            },
          ),

          TextField(
            controller: contentCtrl,
            decoration: const InputDecoration(labelText: 'Chapter content (text)'),
            maxLines: 6,
            onChanged: (v) {
              final nextContent = [
                BookContentItemEntity(type: 'text', value: v),
                ...chapter.content.where((c) => c.type != 'text'),
              ];
              widget.onChanged(BookChapterEntity(title: chapter.title, content: nextContent));
            },
          ),

          const SizedBox(height: 10),

          // Buttons row (ONLY buttons here)
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
  try {
    final url = await widget.pickAndUploadImage();
    if (url == null) return;

    final nextContent = [
      ...chapter.content,
      BookContentItemEntity(type: 'image', value: url),
    ];
    widget.onChanged(BookChapterEntity(title: chapter.title, content: nextContent));
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add image: $e')),
    );
  }
},
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add image'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  final nextContent = [
                    ...chapter.content,
                    const BookContentItemEntity(type: 'text', value: ''),
                  ];
                  widget.onChanged(BookChapterEntity(title: chapter.title, content: nextContent));
                },
                icon: const Icon(Icons.notes),
                label: const Text('Add text block'),
              ),
            ],
          ),

          // Render image blocks BELOW the row (not inside row)
          const SizedBox(height: 10),
          ...chapter.content.asMap().entries
              .where((e) => e.value.type == 'image')
              .map((entry) {
            final idx = entry.key;
            final item = entry.value;

            final displayUrl = item.value.startsWith('http')
                ? item.value
                : item.value.startsWith('/uploads')
                    ? '${ApiEndpoints.serverUrl}${item.value}'
                    : item.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      displayUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      onPressed: () {
                        final next = [...chapter.content]..removeAt(idx);
                        widget.onChanged(BookChapterEntity(title: chapter.title, content: next));
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ),
  );
}
}