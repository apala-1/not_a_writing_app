import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/profile/data/cache/profile_cache.dart';
import 'package:not_a_writing_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:not_a_writing_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_liked_posts_usecase.dart';
import 'package:not_a_writing_app/features/profile/domain/usecases/get_saved_posts_usecase.dart';

final profileCacheProvider = Provider<ProfileCache>((ref) => ProfileCache());

final getLikedPostsUcProvider = Provider((ref) => GetLikedPostsUsecase(ref.read(profileRepositoryProvider)));
final getSavedPostsUcProvider = Provider((ref) => GetSavedPostsUsecase(ref.read(profileRepositoryProvider)));