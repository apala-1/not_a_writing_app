import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/liked_saved_posts_vm_provider.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/liked_saved_posts_state.dart';
import 'package:not_a_writing_app/features/posts/presentation/widgets/post_card.dart';

class LikedSavedPostsPage extends ConsumerWidget {
  const LikedSavedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(likedSavedPostsVmProvider);
    final vm = ref.read(likedSavedPostsVmProvider.notifier);
  
    return Scaffold(
      appBar: AppBar(title: const Text('Your activity')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _IconToggle(
                selected: state.tab == LikedSavedTab.liked,
                icon: Icons.favorite,
                label: 'Liked',
                onTap: () => vm.load(tab: LikedSavedTab.liked),
              ),
              const SizedBox(width: 18),
              _IconToggle(
                selected: state.tab == LikedSavedTab.saved,
                icon: Icons.bookmark,
                label: 'Saved',
                onTap: () => vm.load(tab: LikedSavedTab.saved),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              actions: [
                TextButton(onPressed: () => vm.load(), child: const Text('Retry')),
              ],
            ),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.posts.isEmpty
                    ? Center(
                        child: Text(
                          state.tab == LikedSavedTab.liked ? 'No liked posts yet' : 'No saved posts yet',
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.posts.length,
                        itemBuilder: (_, i) {
                          // inside itemBuilder:
final p = state.posts[i];

return Container(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  clipBehavior: Clip.antiAlias,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // BIG ATTACHMENT (top)
      if (p.attachments.isNotEmpty)
        AspectRatio(
          aspectRatio: 16 / 10, // big + consistent height
          child: Image.network(
            p.attachments.first.url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),

      // Body
      Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (p.author?.profilePictureUrl != null)
                      ? NetworkImage(p.author!.profilePictureUrl!)
                      : null,
                  child: p.author?.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.author?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Unlike / Unsave buttons
                IconButton(
                  icon: Icon(p.isLiked ? Icons.favorite : Icons.favorite_border),
                  color: p.isLiked ? Colors.red : Colors.grey,
                  onPressed: () => vm.toggleLikeFromHere(p.id),
                  tooltip: p.isLiked ? 'Unlike' : 'Like',
                ),
                IconButton(
                  icon: Icon(p.isSaved ? Icons.bookmark : Icons.bookmark_border),
                  color: p.isSaved ? Colors.orange : Colors.grey,
                  onPressed: () => vm.toggleSaveFromHere(p.id),
                  tooltip: p.isSaved ? 'Unsave' : 'Save',
                ),
              ],
            ),

            const SizedBox(height: 10),

            if ((p.title ?? '').isNotEmpty) ...[
              Text(
                p.title!,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 6),
            ],

            Text(
              (p.content ?? '').trim(),
              style: const TextStyle(height: 1.35),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text('${p.likesCount} likes', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(width: 12),
                Text('${p.savesCount} saves', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(width: 12),
                Text('${p.commentsCount} comments', style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconToggle({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.orange : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5)),
          color: selected ? Colors.orange.withOpacity(0.12) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}