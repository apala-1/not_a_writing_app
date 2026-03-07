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

 @override
void initState() {
  super.initState();
  fetchMutualUsers().then((_) => fetchUnreadCounts());
}

  Map<String, int> unreadByUserId = {};

Future<void> fetchUnreadCounts() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final userSessionService = UserSessionService(prefs: sharedPrefs);
  final apiClient = ApiClient(userSessionService);

  final res = await apiClient.get("${ApiEndpoints.baseUrl}/chat/unread-counts");
  final list = (res.data['data'] as List).cast<Map<String, dynamic>>();

  setState(() {
    unreadByUserId = {
      for (final row in list) row['_id'].toString(): (row['unreadCount'] as num).toInt()
    };
  });
}

  Future<void> fetchMutualUsers() async {
    setState(() => loading = true);

    final sharedPrefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs: sharedPrefs);
    final myId = userSessionService.getUserId();

    final apiClient = ApiClient(userSessionService);

    final res = await apiClient.get(
      "${ApiEndpoints.baseUrl}/follow/mutuals/$myId",
    );

    setState(() {
      users = res.data['data'];
      loading = false;
    });
  }

  Future<void> _navigateToChatScreen(String userId, String receiverName) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final userSessionService = UserSessionService(prefs: sharedPrefs);
  final myId = userSessionService.getUserId();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        myUserId: myId!,
        otherUserId: userId,
        otherName: receiverName,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
  onTap: () async {
    await _navigateToChatScreen(user['_id'], user['name']);
    await fetchUnreadCounts(); // ✅ refresh badge after returning
  },
  leading: Stack(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage("${ApiEndpoints.serverUrl}/uploads/${user['profilePicture']}"),
      ),
      if ((unreadByUserId[user['_id']] ?? 0) > 0)
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${unreadByUserId[user['_id']]!}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ],
  ),
  title: Text(user['name']),
);
              },
            ),
    );
  }
}