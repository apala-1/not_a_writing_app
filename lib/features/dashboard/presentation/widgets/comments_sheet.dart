import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/comments_providers.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  String _pfp(String? v) {
    if (v == null || v.isEmpty) return '';
    if (v.startsWith('http')) return v;
    return '${ApiEndpoints.serverUrl}/uploads/$v';
  }

  Future<String?> _askText({
    required BuildContext context,
    required String title,
    String initial = '',
    String hint = '',
    String okText = 'Save',
  }) async {
    final c = TextEditingController(text: initial);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          decoration: InputDecoration(hintText: hint),
          minLines: 1,
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(okText)),
        ],
      ),
    );
    if (ok == true) return c.text;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsVmProvider(widget.postId));
    final vm = ref.read(commentsVmProvider(widget.postId).notifier);
    final myId = ref.read(userSessionServiceProvider).getUserId();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Divider(),
              if (state.loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: state.error != null
                   ? Center(child: Text(state.error!))
      : RefreshIndicator(
          onRefresh: () => vm.load(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.comments.length,
            itemBuilder: (_, i) {
                          final cmt = state.comments[i];
                          final isMine = (myId != null && cmt.user.id == myId);

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (cmt.user.profilePicture == null || cmt.user.profilePicture!.isEmpty)
                                      ? null
                                      : NetworkImage(_pfp(cmt.user.profilePicture)),
                                  child: (cmt.user.profilePicture == null || cmt.user.profilePicture!.isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(cmt.user.name),
                                subtitle: Text(cmt.content),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'reply') {
                                      final text = await _askText(
                                        context: context,
                                        title: 'Reply',
                                        hint: 'Write a reply...',
                                        okText: 'Send',
                                      );
                                      if (text != null) await vm.reply(cmt.id, text);
                                    }

                                    if (v == 'edit') {
                                      final text = await _askText(
                                        context: context,
                                        title: 'Edit comment',
                                        initial: cmt.content,
                                        okText: 'Save',
                                      );
                                      if (text != null) await vm.edit(cmt.id, text);
                                    }

                                    if (v == 'delete') {
                                      await vm.remove(cmt.id);
                                    }
                                  },
                                  itemBuilder: (_) {
                                    final items = <PopupMenuEntry<String>>[
                                      const PopupMenuItem(value: 'reply', child: Text('Reply')),
                                    ];
                                    if (isMine) {
                                      items.addAll(const [
                                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                                      ]);
                                    }
                                    return items;
                                  },
                                ),
                              ),

                              // Replies list
                              if (cmt.replies.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 52, right: 12, bottom: 8),
                                  child: Column(
                                    children: cmt.replies.map((r) {
                                      final isReplyMine = (myId != null && r.user.id == myId);

                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundImage: (r.user.profilePicture == null || r.user.profilePicture!.isEmpty)
                                              ? null
                                              : NetworkImage(_pfp(r.user.profilePicture)),
                                          child: (r.user.profilePicture == null || r.user.profilePicture!.isEmpty)
                                              ? const Icon(Icons.person, size: 16)
                                              : null,
                                        ),
                                        title: Text(
                                          r.user.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(r.content),
                                        trailing: isReplyMine
                                            ? PopupMenuButton<String>(
                                                onSelected: (v) async {
                                                  if (v == 'edit') {
                                                    final text = await _askText(
                                                      context: context,
                                                      title: 'Edit reply',
                                                      initial: r.content,
                                                      okText: 'Save',
                                                    );
                                                    if (text != null) await vm.edit(r.id, text);
                                                  }
                                                  if (v == 'delete') await vm.remove(r.id);
                                                },
                                                itemBuilder: (_) => const [
                                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                ],
                                              )
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                                ),

                              const Divider(height: 1),
                            ],
                          );
                        },
                      ),
              ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        decoration: const InputDecoration(hintText: 'Write a comment...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final t = ctrl.text;
                        ctrl.clear();
                        await vm.addComment(t);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}