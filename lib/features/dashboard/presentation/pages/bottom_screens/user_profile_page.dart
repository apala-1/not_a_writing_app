import 'package:flutter/material.dart';
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
    setState(() => loading = true);

   // 1️⃣ Get user details
    final res = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.getProfile(widget.userId)}");
    userDetails = res.data['data'];

    // 2️⃣ Get user posts
    final postsRes = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.getOwnPosts(widget.userId)}");
    posts = postsRes.data['data'];

    // 3️⃣ Check if current user can message
    final msgRes = await apiClient.get("${ApiEndpoints.baseUrl}${ApiEndpoints.canMessage(myId!, widget.userId)}");
    canMessage = msgRes.data['canMessage'] ?? false;

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(userDetails?['name'] ?? "Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "${ApiEndpoints.serverUrl}/uploads/${userDetails?['profilePicture'] ?? ''}",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userDetails?['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(userDetails?['bio'] ?? ''),
            const SizedBox(height: 12),
            if (canMessage && myId != null)
              ElevatedButton(
                onPressed: () {
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
                child: const Text("Message"),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(post['title']),
                    subtitle: Text(post['description'] ?? ''),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}