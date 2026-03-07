import 'package:flutter/material.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/comments_sheet.dart';
import 'package:not_a_writing_app/features/posts/domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  /// optional: enable actions depending on where it's used
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final bool showCommentsButton;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
    this.showCommentsButton = true,
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
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (pfp != null && pfp.isNotEmpty) ? NetworkImage(pfp) : null,
                child: (pfp == null || pfp.isEmpty) ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  author?.name ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: post.status == "draft"
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(post.status),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if ((post.title ?? '').isNotEmpty) ...[
            Text(
              post.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
          ],

          Text(
            post.content ?? '',
            style: const TextStyle(height: 1.4),
          ),

          const SizedBox(height: 12),

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
                        url,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 160,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: "${post.likesCount}",
                color: post.isLiked ? Colors.red : null,
                onTap: onLike,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: "${post.savesCount}",
                color: post.isSaved ? Colors.amber : null,
                onTap: onSave,
              ),
              const SizedBox(width: 26),
              if (showCommentsButton)
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
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
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