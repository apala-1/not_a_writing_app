import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/posts/data/cache/dashboard_feed_cache.dart';

final dashboardFeedCacheProvider = Provider<DashboardFeedCache>((ref) {
  return DashboardFeedCache();
});