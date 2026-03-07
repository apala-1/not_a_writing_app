import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/follow_service.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/user_profile_page.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/follow_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  late final ApiClient apiClient;
  late FollowService followService; 

  List users = [];
  bool loading = false;
  String query = "";

  // Theme Constants
  static const Color primaryOrange = Color(0xFFFF7F00);
  static const Color roseAccent = Color(0xFFF25C78);
  static const Color softRose = Color(0xFFFFF1F2);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    initServices();
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: userId),
      ),
    );
  }

  Future<void> initServices() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs: sharedPrefs);
    apiClient = ApiClient(userSessionService);
    followService = FollowService(apiClient.dio);
    if (mounted) setState(() {});
  }

  Future<void> search(String value) async {
    if (value.isEmpty) {
      setState(() => users = []);
      return;
    }

    setState(() => loading = true);

    try {
      final res = await apiClient.get(
        "${ApiEndpoints.baseUrl}${ApiEndpoints.searchUsers(value)}",
      );

      setState(() {
        users = res.data['data'] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      // Handle error gracefully if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          "Find Writers",
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.person_search_rounded, color: primaryOrange.withOpacity(0.5)),
          )
        ],
      ),
      body: Column(
        children: [
          // 🔎 Modern Search Bar Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                query = value;
                search(value);
              },
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Search by name or bio...",
                hintStyle: const TextStyle(color: textGray, fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange),
                filled: true,
                fillColor: bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: query.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: textGray, size: 20),
                      onPressed: () {
                        setState(() => query = "");
                        search("");
                      },
                    )
                  : null,
              ),
            ),
          ),

          // 📋 Results List
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                : users.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? "Discover new storytellers" : "No writers found for '$query'",
            style: const TextStyle(color: textGray, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final profilePic = user['profilePicture'];
    final imageUrl = profilePic != null && profilePic.isNotEmpty
        ? "${ApiEndpoints.serverUrl}/uploads/$profilePic"
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _navigateToUserProfile(user['_id']),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: softRose, width: 2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: softRose,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null 
              ? const Icon(Icons.person_rounded, color: primaryOrange, size: 30) 
              : null,
          ),
        ),
        title: Text(
          user['name'] ?? "Anonymous Writer",
          style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            user['bio'] ?? "No bio available yet.",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: textGray, fontSize: 13),
          ),
        ),
        trailing: SizedBox(
          width: 90,
          child: FollowButton(
            userId: user['_id'],
            service: followService,
          ),
        ),
      ),
    );
  }
}