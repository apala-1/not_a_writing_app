import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/comments_view_model.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/profile/presentation/viewmodel/profile_view_model.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(commentViewModelProvider.notifier)
          .loadCommentsWithProfiles(widget.postId, ref);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CommentWithProfile? _editingComment;

void _postComment() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  if (_editingComment != null) {
    // Editing existing comment
    await ref
        .read(commentViewModelProvider.notifier)
        .update(_editingComment!.comment.id, text, widget.postId);
    _editingComment = null; // reset after update
  } else {
    // New comment
    await ref.read(commentViewModelProvider.notifier).add(widget.postId, text);
  }

  _controller.clear();
}

  void _showCommentOptions(CommentWithProfile comment) {
    final currentUserId =
        ref.read(userSessionServiceProvider).getUserId() ?? '';

    final isOwner = comment.comment.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwner)
            ListTile(
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                _controller.text = comment.comment.content;
                _editingComment = comment;
              },
            ),
          if (isOwner)
            ListTile(
              title: const Text("Delete"),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(commentViewModelProvider.notifier)
                    .delete(comment.comment.id, widget.postId);
              },
            ),
          if (!isOwner)
            ListTile(
              title: const Text("Report"),
              onTap: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentViewModelProvider);
    final profiles = ref.watch(profileViewmodelProvider).profileEntity;

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: state.comments.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final commentProfile = comment.userProfile;
                        return GestureDetector(
                          onLongPress: () => _showCommentOptions(comment),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(commentProfile?.profilePicture ?? ''),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person),
                            ),
                            title: Text(commentProfile?.name ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.comment.content),
                                const SizedBox(height: 4),
                                Text(
                                  comment.createdAtFormatted,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _postComment,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
