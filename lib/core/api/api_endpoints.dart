import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  // static const bool isPhysicalDevice = false;
  static const String _ipAddress = "10.105.246.66";
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) {
      return _ipAddress;
    }
    // if(Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1';
  static String get mediaServerUrl => serverUrl;

    // ===== AUTH (USER) =====
  static const String auth = '/auth';

  static const String register = '$auth/register';
  static const String login = '$auth/login';

  static const String forgotPassword = '$auth/forgot-password';
static const String resetPassword = '$auth/reset-password';

  static const String me = '$auth/me';
  static const String updateMe = '$auth/me';
  static const String deleteMe = '$auth/me';
  static const String googleLogin = '$auth/google-login';

  // ===== ADMIN USERS =====
  static const String users = '/users';

  static String userById(String id) => '/users/$id';

  // ===== MEDIA =====
  static String media(String filename) => '$serverUrl/uploads/$filename';

  // ===== POSTS =====
static const String posts = '/post';

// GET /post
static String getAllPosts() => posts;

// GET /post/drafts
static String getDrafts() => '$posts/drafts';

// GET /post/feed
static String getFeed() => '$posts/feed';

// GET /post/:id
static String getPostById(String id) => '$posts/$id';

// POST /post
static String createPost() => posts;

// PUT /post/:id
static String updatePost(String id) => '$posts/$id';

// DELETE /post/:id
static String deletePost(String id) => '$posts/$id';

// POST /post/toggle-like/:postId
static String toggleLike(String postId) => '$posts/toggle-like/$postId';

// POST /post/toggle-save/:postId
static String toggleSave(String postId) => '$posts/toggle-save/$postId';

// POST /post/:id/view
static String addView(String postId) => '$posts/$postId/view';

// POST /post/:id/share
static String addShare(String postId) => '$posts/$postId/share';

// GET /post/ranked-feed/:userId
static String rankedFeed(String userId) => '$posts/ranked-feed/$userId';

// GET /profile/:userId/posts
static String getOwnPosts(String userId) => '$profile/profile/$userId/posts';

// ===== PROFILE =====
static const String profile = '/profile';

// GET /profile/:id
static String getProfile(String id) => '$profile/profile/$id';

// POST /profile/follow
static String follow() => '$profile/follow';

// POST /profile/unfollow
static String unfollow() => '$profile/unfollow';

// POST /profile/post-action
static String postAction() => '$profile/post-action';

// ===== COMMENTS =====
static const String comments = '/comments';

// GET /comments/post/:postId
static String getCommentsByPost(String postId) =>
    '$comments/post/$postId';

// POST /comments
static String createComment() => comments;

// PATCH /comments/:id
static String updateComment(String commentId) =>
    '$comments/$commentId';

// DELETE /comments/:id
static String deleteComment(String commentId) =>
    '$comments/$commentId';

// GET /comments/whole-comment/:userId
static String getWholeCommentWithProfile(String userId) =>
    '$comments/whole-comment/$userId';

// ===== FOLLOW =====
static const String followBase = '/follow';

// POST /follow/follow
static String followUser() => '$followBase/follow';

// POST /follow/unfollow
static String unfollowUser() => '$followBase/unfollow';

// GET /follow/followers/:userId
static String getFollowers(String userId) =>
    '$followBase/followers/$userId';

// GET /follow/following/:userId
static String getFollowing(String userId) =>
    '$followBase/following/$userId';

// GET /follow/status/:userId
static String followStatus(String userId) =>
    '$followBase/status/$userId';

// GET /follow/count/:userId
static String followCount(String userId) =>
    '$followBase/count/$userId';

// GET /follow/can-message/:userA/:userB
static String canMessage(String userA, String userB) =>
    '$followBase/can-message/$userA/$userB';

static String searchUsers(String query) =>
    '/follow/search?q=$query';

// ===== CHAT =====
static const String chat = '/chat';

// POST /chat/send
static String sendMessage() => '$chat/send';

// GET /chat/conversation/:userA/:userB
static String getConversation(String userA, String userB) => '$chat/conversation/$userA/$userB';

  // ===== TIMEOUTS =====
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

}