import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  String? existingCoverUrl;

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);
  static const Color inputBg = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    if (widget.args is CreateBookArgs) {
      chapters = List.of((widget.args as CreateBookArgs).initialChapters);
    } else {
      _loadForEdit();
    }
  }

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
      existingCoverUrl = book.coverPhotoUrl;

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
    setState(() { loading = true; error = null; });
    try {
      if (chapters.isEmpty) throw Exception('A book must have at least one chapter');
      final title = titleCtrl.text.trim();
      final desc = descCtrl.text.trim();
      if (title.isEmpty || desc.isEmpty) throw Exception('Title and description are required');

      if (widget.args is CreateBookArgs) {
        if (coverFile == null) throw Exception('Cover photo is required');
        await ref.read(createBookUcProvider)(
          title: title,
          description: desc,
          visibility: visibility,
          asDraft: draft,
          chapters: chapters,
          coverPhotoFile: coverFile!,
        );
      } else {
        await ref.read(updateBookUcProvider)(
          bookId: (widget.args as EditBookArgs).existingBookId,
          title: title,
          description: desc,
          visibility: visibility,
          asDraft: draft,
          chapters: chapters,
          coverPhotoFile: coverFile,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { loading = false; error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && (widget.args is EditBookArgs) && chapters.isEmpty) {
      return const Scaffold(backgroundColor: bgColor, body: Center(child: CircularProgressIndicator(color: orangePrimary)));
    }

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _buildBlob(200, orangePrimary.withOpacity(0.1))),
          Positioned(bottom: 100, right: -50, child: _buildBlob(250, rosePrimary.withOpacity(0.08))),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                if (error != null) _buildErrorBanner(),
                
                // Cover Picker Card
                _buildSectionHeader("Book Cover"),
                _buildCoverPicker(),
                const SizedBox(height: 24),
                
                // Details Card
                _buildSectionHeader("Story Details"),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                
                // Chapters Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Manuscript"),
                    TextButton.icon(
                      onPressed: loading ? null : _addChapter,
                      icon: Icon(LucideIcons.circleAlert, size: 18),
                      label: const Text("Add Chapter"),
                      style: TextButton.styleFrom(foregroundColor: orangePrimary),
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
                    onChanged: (updated) => setState(() => chapters = [...chapters]..[i] = updated),
                    onRemove: chapters.length <= 1 ? null : () => _removeChapter(i),
                    pickAndUploadImage: () async {
                      final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (x == null) return null;
                      return await ref.read(booksRepositoryProvider).uploadChapterImage(File(x.path));
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: const BackButton(color: Colors.black87),
      title: Text(
        widget.args is CreateBookArgs ? 'New Story' : 'Edit Story',
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: _buildGradientButton(
            text: loading ? "..." : "Save",
            onPressed: loading ? null : _save,
            width: 80,
          ),
        )
      ],
    );
  }

  Widget _buildCoverPicker() {
    return _buildGlassCard(
      child: Row(
        children: [
          Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: coverFile != null
                  ? Image.file(coverFile!, fit: BoxFit.cover)
                  : (existingCoverUrl != null
                      ? Image.network(existingCoverUrl!, fit: BoxFit.cover)
                      : Container(color: orangePrimary.withOpacity(0.1), child: const Icon(LucideIcons.image, color: orangePrimary))),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: loading ? null : _pickCover,
                  icon: const Icon(LucideIcons.camera, size: 18),
                  label: Text(coverFile == null ? 'Pick cover' : 'Change cover'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: orangePrimary,
                    side: const BorderSide(color: orangePrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coverFile != null ? 'New image selected' : (existingCoverUrl != null ? 'Current cover active' : 'Resolution: 900x1200 recommended'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          _buildTextField(controller: titleCtrl, hint: "Book Title", icon: LucideIcons.book),
          const SizedBox(height: 16),
          _buildTextField(controller: descCtrl, hint: "Brief Description", icon: LucideIcons.panelLeft, maxLines: 3),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: visibility,
            items: const [
              DropdownMenuItem(value: 'private', child: Text('Private')),
              DropdownMenuItem(value: 'public', child: Text('Public')),
            ],
            onChanged: loading ? null : (v) => setState(() => visibility = v ?? 'private'),
            decoration: _inputDecoration(LucideIcons.globe, "Visibility"),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: draft,
            activeColor: orangePrimary,
            onChanged: loading ? null : (v) => setState(() => draft = v),
            title: const Text('Save as draft', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // Common Helpers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: Colors.black54)),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(icon, hint),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: orangePrimary.withOpacity(0.6)),
      filled: true, fillColor: inputBg,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: orangePrimary, width: 2)),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback? onPressed, double? width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : const LinearGradient(colors: [orangePrimary, rosePrimary]),
        color: onPressed == null ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 16)),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)));
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [ Icon(LucideIcons.circleAlert, color: Colors.redAccent, size: 20), const SizedBox(width: 12), Expanded(child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)))]),
    );
  }
}

class _ChapterEditor extends StatefulWidget {
  final int index;
  final BookChapterEntity chapter;
  final ValueChanged<BookChapterEntity> onChanged;
  final VoidCallback? onRemove;
  final Future<String?> Function() pickAndUploadImage;

  const _ChapterEditor({super.key, required this.index, required this.chapter, required this.onChanged, required this.onRemove, required this.pickAndUploadImage});

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
    final textItem = widget.chapter.content.firstWhere((c) => c.type == 'text', orElse: () => const BookContentItemEntity(type: 'text', value: ''));
    contentCtrl = TextEditingController(text: textItem.value);
  }

  @override
  void dispose() { titleCtrl.dispose(); contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('CHAPTER ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF97316), fontSize: 12)),
              ),
              const Spacer(),
              if (widget.onRemove != null) IconButton(onPressed: widget.onRemove, icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleCtrl,
            decoration: _innerInput("Chapter Title", LucideIcons.type),
            onChanged: (v) => widget.onChanged(BookChapterEntity(title: v, content: widget.chapter.content)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentCtrl,
            maxLines: 6,
            decoration: _innerInput("Write your story content here...", LucideIcons.moveLeft),
            onChanged: (v) {
              final next = [BookContentItemEntity(type: 'text', value: v), ...widget.chapter.content.where((c) => c.type != 'text')];
              widget.onChanged(BookChapterEntity(title: widget.chapter.title, content: next));
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _tinyButton(LucideIcons.image, "Add Image", () async {
                final url = await widget.pickAndUploadImage();
                if (url == null) return;
                final next = [...widget.chapter.content, BookContentItemEntity(type: 'image', value: url)];
                widget.onChanged(BookChapterEntity(title: widget.chapter.title, content: next));
              }),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.chapter.content.asMap().entries.where((e) => e.value.type == 'image').map((entry) {
            return _buildImageBlock(entry.key, entry.value.value);
          }),
        ],
      ),
    );
  }

  Widget _buildImageBlock(int idx, String url) {
    final displayUrl = url.startsWith('http') ? url : '${ApiEndpoints.serverUrl}$url';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(displayUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.grey[200], child: const Icon(LucideIcons.imageOff))),
          ),
          Positioned(
            right: 8, top: 8,
            child: GestureDetector(
              onTap: () {
                final next = [...widget.chapter.content]..removeAt(idx);
                widget.onChanged(BookChapterEntity(title: widget.chapter.title, content: next));
              },
              child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.x, size: 16, color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _innerInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, size: 16, color: Colors.grey),
      filled: true, fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _tinyButton(IconData icon, String text, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap, icon: Icon(icon, size: 16), label: Text(text, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF97316), side: const BorderSide(color: Color(0xFFF97316)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}