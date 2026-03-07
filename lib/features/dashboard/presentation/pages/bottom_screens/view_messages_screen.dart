import 'package:flutter/material.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/pages/bottom_screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewMessagesScreen extends StatefulWidget {
  const ViewMessagesScreen({super.key});

  @override
  State<ViewMessagesScreen> createState() => _ViewMessagesScreenState();
}

class _ViewMessagesScreenState extends State<ViewMessagesScreen> {
  List users = [];
  bool loading = false;
  Map<String, int> unreadByUserId = {};

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
    _initData();
  }

  Future<void> _initData() async {
    await fetchMutualUsers();
    await fetchUnreadCounts();
  }

  Future<void> fetchUnreadCounts() async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: sharedPrefs);
      final apiClient = ApiClient(userSessionService);

      final res = await apiClient.get("${ApiEndpoints.baseUrl}/chat/unread-counts");
      final list = (res.data['data'] as List).cast<Map<String, dynamic>>();

      if (mounted) {
        setState(() {
          unreadByUserId = {
            for (final row in list) row['_id'].toString(): (row['unreadCount'] as num).toInt()
          };
        });
      }
    } catch (e) {
      debugPrint("Error fetching unread counts: $e");
    }
  }

  Future<void> fetchMutualUsers() async {
    if (mounted) setState(() => loading = true);

    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: sharedPrefs);
      final myId = userSessionService.getUserId();
      final apiClient = ApiClient(userSessionService);

      final res = await apiClient.get(
        "${ApiEndpoints.baseUrl}/follow/mutuals/$myId",
      );

      if (mounted) {
        setState(() {
          users = res.data['data'];
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _navigateToChatScreen(String userId, String receiverName) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs: sharedPrefs);
    final myId = userSessionService.getUserId();

    if (myId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          myUserId: myId,
          otherUserId: userId,
          otherName: receiverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined, color: primaryOrange),
            onPressed: fetchUnreadCounts,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryOrange))
          : users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _initData,
                  color: primaryOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final unreadCount = unreadByUserId[user['_id']] ?? 0;
                      return _buildChatTile(user, unreadCount);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: softRose,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_rounded, size: 60, color: roseAccent),
          ),
          const SizedBox(height: 20),
          const Text(
            "No conversations yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mutual followers will appear here.",
            style: TextStyle(color: textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> user, int unreadCount) {
    final profilePic = user['profilePicture'];
    final imageUrl = profilePic != null && profilePic.isNotEmpty
        ? "${ApiEndpoints.serverUrl}/uploads/profiles/$profilePic"
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          await _navigateToChatScreen(user['_id'], user['name']);
          await fetchUnreadCounts(); 
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: unreadCount > 0 ? primaryOrange : softRose, width: 2),
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
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: roseAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user['name'] ?? "Unknown User",
          style: TextStyle(
            fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.bold,
            color: textDark,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            user['bio'] ?? "Tap to start chatting",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unreadCount > 0 ? textDark.withOpacity(0.7) : textGray,
              fontSize: 13,
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black12),
      ),
    );
  }
}
