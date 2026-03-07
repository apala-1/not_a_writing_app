import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_service.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/comments_sheet.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final double _shakeThreshold = 20.0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final pos = _scroll.position;
      if (pos.pixels > pos.maxScrollExtent - 300) {
        ref.read(dashboardVmProvider.notifier).loadMore();
      }
    });
    _startShakeDetection();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 200) {
      ref.read(dashboardVmProvider.notifier).loadMore();
    }
  }

  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color softRose = Color(0xFFFFF1F2);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);

  void _startShakeDetection() {
  _accelerometerSubscription =
      accelerometerEventStream().listen((AccelerometerEvent event) async {
    double acceleration =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if (acceleration > _shakeThreshold && !_isRefreshing) {
      setState(() => _isRefreshing = true);

      if (_scroll.hasClients) {
        await _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }

      await ref.read(dashboardVmProvider.notifier).refresh();

      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  });
}

  Future<void> _showCreateDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool draft = false;
    final picked = <File>[];

    Future<void> pickImages(StateSetter setModalState) async {
      final images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isEmpty) return;
      final remaining = 5 - picked.length;
      picked.addAll(images.take(remaining).map((x) => File(x.path)));
      setModalState(() {});
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Create New Story', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledField(titleCtrl, 'Story Title', Icons.title_rounded),
                  const SizedBox(height: 16),
                  _buildStyledField(descCtrl, 'Short Summary', Icons.notes_rounded),
                  const SizedBox(height: 16),
                  _buildStyledField(contentCtrl, 'Share your thoughts...', Icons.edit_note_rounded, maxLines: 5),
                  const SizedBox(height: 24),
                  
                  // Image Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      Text('${picked.length}/5', style: const TextStyle(color: textGray, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: picked.length >= 5 ? null : () => pickImages(setModalState),
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                        label: const Text('Add Images'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (picked.isNotEmpty)
                        TextButton(
                          onPressed: () => setModalState(() => picked.clear()),
                          child: const Text('Clear All', style: TextStyle(color: roseAccent, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  if (picked.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: picked.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _buildImagePreview(picked[i], () => setModalState(() => picked.removeAt(i))),
                      ),
                    ),
                  ],
                  const Divider(height: 40, thickness: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryOrange,
                    value: draft,
                    onChanged: (v) => setModalState(() => draft = v),
                    title: const Text('Save as Draft', style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
                    subtitle: const Text('Only visible to you until published', style: TextStyle(fontSize: 12)),
                    secondary: Icon(Icons.drafts_rounded, color: draft ? primaryOrange : textGray),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: textGray, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: primaryOrange.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Post Story', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await ref.read(dashboardVmProvider.notifier).onCreatePost(
            title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
            content: contentCtrl.text.trim(),
            asDraft: draft,
            attachments: picked,
          );
      await ref.read(dashboardVmProvider.notifier).refresh();
    }
  }

  Future<void> _showEditDialog(PostEntity post) async {
    final titleCtrl = TextEditingController(text: post.title ?? '');
    final descCtrl = TextEditingController(text: post.description ?? '');
    final contentCtrl = TextEditingController(text: post.content ?? '');
    bool draft = post.status == 'draft';
    final keepExisting = post.attachments.where((a) => a.id != null).toList();
    final newPicked = <File>[];

    Future<void> pickNewImages(StateSetter setModalState) async {
      final images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isEmpty) return;
      final remaining = 5 - (keepExisting.length + newPicked.length);
      if (remaining <= 0) return;
      newPicked.addAll(images.take(remaining).map((x) => File(x.path)));
      setModalState(() {});
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Story', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledField(titleCtrl, 'Title', Icons.title_rounded),
                  const SizedBox(height: 16),
                  _buildStyledField(descCtrl, 'Description', Icons.description_outlined),
                  const SizedBox(height: 16),
                  _buildStyledField(contentCtrl, 'Story Content', Icons.edit_note_rounded, maxLines: 5),
                  const SizedBox(height: 24),
                  
                  // Existing Attachments
                  if (keepExisting.isNotEmpty) ...[
                    _buildSectionHeader('Current Photos', '${keepExisting.length} kept'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: keepExisting.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _buildNetworkPreview(keepExisting[i].url, () => setModalState(() => keepExisting.removeAt(i))),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // New Attachments Section
                  _buildSectionHeader('Add New Photos', '${newPicked.length} added'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: (keepExisting.length + newPicked.length) >= 5 ? null : () => pickNewImages(setModalState),
                        icon: const Icon(Icons.add_a_photo_rounded, size: 20),
                        label: const Text('Select More'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  if (newPicked.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: newPicked.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _buildImagePreview(newPicked[i], () => setModalState(() => newPicked.removeAt(i))),
                      ),
                    ),
                  ],
                  
                  const Divider(height: 40, thickness: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryOrange,
                    value: draft,
                    onChanged: (v) => setModalState(() => draft = v),
                    title: const Text('Draft Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                    secondary: Icon(Icons.auto_fix_high_rounded, color: draft ? primaryOrange : textGray),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard', style: TextStyle(color: textGray, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final keepIds = keepExisting.map((a) => a.id!).toList();
      await ref.read(dashboardVmProvider.notifier).onUpdatePost(
            postId: post.id,
            title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
            description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
            content: contentCtrl.text.trim().isEmpty ? null : contentCtrl.text.trim(),
            asDraft: draft,
            newAttachments: newPicked,
            keepExistingAttachmentIds: keepIds,
          );
      await ref.read(dashboardVmProvider.notifier).refresh();
    }
  }

  // --- UI Styling Helpers ---

  Widget _buildStyledField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textGray, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryOrange, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryOrange, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
        Text(subtitle, style: const TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImagePreview(File file, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkPreview(String url, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey.shade200, child: const Icon(Icons.broken_image_rounded, color: Colors.grey)),
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardVmProvider);
    final vm = ref.read(dashboardVmProvider.notifier);

    return Scaffold(
       floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryOrange, roseAccent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: roseAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      body: Column(
  children: [
    if (state.error != null)
      MaterialBanner(
        content: Text(state.error!),
        actions: [
          TextButton(onPressed: () => vm.refresh(), child: const Text('Retry')),
        ],
      ),

    Expanded(
  child: _isRefreshing
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView.separated(
                controller: _scroll,
                itemCount: state.posts.length + (state.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  if (index >= state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final post = state.posts[index];
                 final currentUserId = ref.read(userSessionServiceProvider).getUserId();
final isMine = post.author?.id == currentUserId;
print('aUTHOR: ${post.author?.id}');
print("cURRENT USER: ${currentUserId}");

return _PostTile(
  post: post,
  isMine: isMine,
  onEdit: () => _showEditDialog(post),
  onDelete: () => vm.onDeletePost(post.id),
  onLike: () => vm.onToggleLike(post.id),
  onSave: () => vm.onToggleSave(post.id),
);
                },
              ),
            ),
          ),
  ],
      ),
      );
  }
}


class _PostTile extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final bool isMine;

  const _PostTile({
    required this.post,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onSave, required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final pfp = author?.profilePictureUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Author row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (pfp != null) ? NetworkImage(pfp) : null,
                child: pfp == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  author?.name ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              PopupMenuButton<String>(
  onSelected: (v) {
    if (v == 'edit') onEdit();
    if (v == 'delete') onDelete();
    if (v == 'report') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post reported")),
      );
    }
  },
  itemBuilder: (_) {
    if (isMine) {
      return const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ];
    } else {
      return const [
        PopupMenuItem(value: 'report', child: Text('Report')),
      ];
    }
  },
),
            ],
          ),

          const SizedBox(height: 12),

          /// Title
          if ((post.title ?? '').isNotEmpty)
            Text(
              post.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          if ((post.title ?? '').isNotEmpty)
            const SizedBox(height: 6),

          /// Content
          Text(
            post.content ?? '',
            style: const TextStyle(height: 1.4),
          ),

          const SizedBox(height: 12),

          /// Attachments preview
          if (post.attachments.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.attachments.length,
                itemBuilder: (_, i) {
                  final url = post.attachments[i].url;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "$url",
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          /// Actions
          Row(
            children: [

              _ActionButton(
  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
  label: "${post.likesCount}",
  onTap: onLike,
  color: post.isLiked ? Colors.red : null,
),

              const SizedBox(width: 16),

             _ActionButton(
  icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
  label: "${post.savesCount}",
  onTap: onSave,
  color: post.isSaved ? Colors.amber : null,
),

const SizedBox(width: 26),

_ActionButton(
  icon: Icons.comment_outlined,
  label: "Comments",
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentsSheet(postId: post.id),
    );
  },
),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: post.status == "draft"
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(post.status),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
final String label;
final VoidCallback onTap;
final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}