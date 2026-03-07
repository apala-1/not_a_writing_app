import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({required this.userId, super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late ApiClient apiClient;
  Map<String, dynamic>? userDetails;
  List posts = [];
  bool canMessage = false;
  bool loading = true;
  String? myId;

  // Theme Colors matching your React app
  static const Color orangePrimary = Color(0xFFF97316); // orange-500
  static const Color rosePrimary = Color(0xFFF43F5E);   // rose-500
  static const Color bgColor = Color(0xFFFFF7ED);       // orange-50
  static const Color cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    initServices();
  }

  Future<void> initServices() async {
    final prefs = await SharedPreferences.getInstance();
    final session = UserSessionService(prefs: prefs);
    apiClient = ApiClient(session);
    myId = session.getUserId();
    await fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final res = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.getProfile(widget.userId)}");
      userDetails = res.data['data'];

      final postsRes = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.getOwnPosts(widget.userId)}");
      posts = postsRes.data['data'];

      if (myId != null) {
        final msgRes = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.canMessage(myId!, widget.userId)}");
        canMessage = msgRes.data['canMessage'] ?? false;
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
              ),
              const SizedBox(height: 16),
              Text(
                "Loading profile...",
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          userDetails?['name'] ?? "Profile",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Gradients/Blobs
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlob(300, orangePrimary.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlob(250, rosePrimary.withOpacity(0.1)),
          ),
          
          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  
                  // Tabs Placeholder (To match React Layout)
                  _buildSectionHeader("Posts"),
                  const SizedBox(height: 12),
                  
                  // Posts List
                  posts.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) => _buildPostCard(posts[index]),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Profile Picture with Gradient Ring
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [orangePrimary, rosePrimary]),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                "${ApiEndpoints.serverUrl}/uploads/profiles/${userDetails?['profilePicture'] ?? ''}",
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userDetails?['name'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(posts.length.toString(), "posts"),
              _buildStatDivider(),
              _buildStatItem(userDetails?['followersCount']?.toString() ?? '0', "followers"),
              _buildStatDivider(),
              _buildStatItem(userDetails?['followingCount']?.toString() ?? '0', "following"),
            ],
          ),
          
          const SizedBox(height: 12),
          Text(
            userDetails?['bio'] ?? 'No bio yet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 20),
          
          // Message Button (Styled like your React one)
          if (canMessage && myId != widget.userId)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      myUserId: myId!,
                      otherUserId: widget.userId,
                      otherName: userDetails?['name'] ?? 'Chat',
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [orangePrimary, rosePrimary]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: rosePrimary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.messageSquare, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Message",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: orangePrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  Widget _buildPostCard(dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: orangePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:  Icon(LucideIcons.pen400, color: orangePrimary),
        ),
        title: Text(
          post['title'] ?? 'Untitled Post',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          post['description'] ?? 'No description',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
        onTap: () {
          // Open post details
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(LucideIcons.layoutGrid400, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No posts yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("Share your first story with the world!", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}