import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  // static const bool isPhysicalDevice = false;
  static const String _ipAddress = "10.141.234.66";
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

  // ===== ADMIN USERS =====
  static const String users = '/users';

  static String userById(String id) => '/users/$id';

  // ===== MEDIA =====
  static String media(String filename) => '$serverUrl/uploads/$filename';

  // ===== POSTS =====
  static const String posts = '/post';
static String getAllPosts() => posts;

// GET /posts/drafts
static String drafts = '$posts/drafts';

// GET /posts/:id
static String getPostById(String id) => '$posts/$id';

// POST /posts
static String createPost() => posts;

// PUT /posts/:id
static String updatePost(String id) => '$posts/$id';

// DELETE /posts/:id
static String deletePost(String id) => '$posts/$id';

static String toggleLike(String postId) => '/posts/toggle-like/$postId';

static String toggleSave(String postId) => '/posts/toggle-save/$postId';

static String addView(String postId) => '/posts/$postId/view';

static String addShare(String postId) => '/posts/$postId/share';

static String rankedFeed(String userId) => '/posts/ranked-feed/$userId';

  // ===== TIMEOUTS =====
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

}