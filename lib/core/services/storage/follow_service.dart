import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';

class FollowService {
  final Dio dio;

  FollowService(this.dio);

  Future<void> follow(String targetUserId) async {
    await dio.post(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.followUser()}",
      data: { "targetUserId": targetUserId },
    );
  }

  Future<void> unfollow(String targetUserId) async {
    await dio.post(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.unfollowUser()}",
      data: { "targetUserId": targetUserId },
    );
  }

  Future<bool> isFollowing(String userId) async {
    final res = await dio.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.followStatus(userId)}",
    );

    return res.data['data']['isFollowing'];
  }

  Future<Map<String, dynamic>> getFollowCount(String userId) async {
    final res = await dio.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.followCount(userId)}",
    );

    return res.data['data'];
  }

  Future<List<dynamic>> getFollowers(String userId) async {
    final res = await dio.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.getFollowers(userId)}",
    );

    return res.data['data'];
  }

  Future<List<dynamic>> getFollowing(String userId) async {
    final res = await dio.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.getFollowing(userId)}",
    );

    return res.data['data'];
  }

  Future<bool> canMessage(String userA, String userB) async {
    final res = await dio.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.canMessage(userA, userB)}",
    );

    return res.data['canMessage'];
  }
}