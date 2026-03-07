import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/profile/data/cache/profile_cache.dart';

final profileCacheProvider = Provider<ProfileCache>((ref) => ProfileCache());