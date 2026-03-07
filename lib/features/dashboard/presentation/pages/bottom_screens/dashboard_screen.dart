import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/services/storage/user_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';
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

      // enforce max 5 like backend
      final remaining = 5 - picked.length;
      final take = images.take(remaining);

      picked.addAll(take.map((x) => File(x.path)));
      setModalState(() {});
    }

    final ok = await showDialog<bool>(
  context: context,
  builder: (_) => StatefulBuilder(
    builder: (context, setModalState) => AlertDialog(
      title: const Text('Create Post'),
      content: SizedBox(
        width: double.maxFinite,
        // constrain dialog height so it doesn't ask for intrinsics
        height: MediaQuery.of(context).size.height * 0.55,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: picked.length >= 5 ? null : () => pickImages(setModalState),
                    icon: const Icon(Icons.photo_library),
                    label: Text('Add images (${picked.length}/5)'),
                  ),
                  const SizedBox(width: 8),
                  if (picked.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        picked.clear();
                        setModalState(() {});
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
              if (picked.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: picked.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            picked[i],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            onPressed: () {
                              picked.removeAt(i);
                              setModalState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                value: draft,
                onChanged: (v) => setModalState(() => draft = v),
                title: const Text('Save as draft'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
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
            attachments: picked, // ✅ send picked files
          );
      await ref.read(dashboardVmProvider.notifier).refresh();
    }
  }

  Future<void> _showEditDialog(PostEntity post) async {
  final titleCtrl = TextEditingController(text: post.title ?? '');
  final descCtrl = TextEditingController(text: post.description ?? '');
  final contentCtrl = TextEditingController(text: post.content ?? '');

  bool draft = post.status == 'draft';

  // existing attachments to keep (start: all)
  final keepExisting = post.attachments
      .where((a) => a.id != null) // must have mongo id to be keep-able
      .toList();

  // new attachments to add
  final newPicked = <File>[];

  Future<void> pickNewImages(StateSetter setModalState) async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    // backend max 5 total; enforce total = keepExisting + newPicked <= 5
    final remaining = 5 - (keepExisting.length + newPicked.length);
    if (remaining <= 0) return;

    final take = images.take(remaining);
    newPicked.addAll(take.map((x) => File(x.path)));

    setModalState(() {});
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) => AlertDialog(
        title: const Text('Edit Post'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.65,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: draft,
                  onChanged: (v) => setModalState(() => draft = v),
                  title: const Text('Draft'),
                ),
                const SizedBox(height: 12),

                // Existing attachments (server)
                Row(
                  children: [
                    const Text('Existing attachments', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${keepExisting.length} kept'),
                  ],
                ),
                const SizedBox(height: 8),
                if (keepExisting.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No existing attachments'),
                  )
                else
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: keepExisting.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final att = keepExisting[i];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                att.url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 90,
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
                                  keepExisting.removeAt(i); // removing means "delete on save"
                                  setModalState(() {});
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // New attachments (local)
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: (keepExisting.length + newPicked.length) >= 5
                          ? null
                          : () => pickNewImages(setModalState),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text('Add new (${newPicked.length})'),
                    ),
                    const SizedBox(width: 8),
                    if (newPicked.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          newPicked.clear();
                          setModalState(() {});
                        },
                        child: const Text('Clear new'),
                      ),
                    const Spacer(),
                    Text('Total: ${keepExisting.length + newPicked.length}/5'),
                  ],
                ),
                const SizedBox(height: 8),
                if (newPicked.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: newPicked.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              newPicked[i],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                              onPressed: () {
                                newPicked.removeAt(i);
                                setModalState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
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
          newAttachments: newPicked, // ✅ add these
          keepExistingAttachmentIds: keepIds, // ✅ keep these
        );

        await ref.read(dashboardVmProvider.notifier).refresh();
  }
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardVmProvider);
    final vm = ref.read(dashboardVmProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
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
                 final currentUserId = ref.read(userSessionProvider).getUserId();
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