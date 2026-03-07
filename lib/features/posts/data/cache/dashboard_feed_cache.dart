import 'package:hive/hive.dart';
import 'package:not_a_writing_app/features/posts/data/models/post_hive_model.dart';

class DashboardFeedCache {
  static const boxName = 'dashboard_feed_cache';
  static const keyPosts = 'posts_v1';
  static const keyCachedAt = 'cached_at_iso';

  Future<Box> _box() => Hive.openBox(boxName);

  Future<List<PostHive>> readPosts() async {
    final box = await _box();
    final raw = box.get(keyPosts);
    if (raw is List) return raw.cast<PostHive>();
    return <PostHive>[];
  }

  Future<void> writePosts(List<PostHive> posts) async {
    final box = await _box();
    await box.put(keyPosts, posts);
    await box.put(keyCachedAt, DateTime.now().toIso8601String());
  }

  Future<void> clear() async {
    final box = await _box();
    await box.delete(keyPosts);
  }
}