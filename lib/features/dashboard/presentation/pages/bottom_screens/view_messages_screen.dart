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
    fetchMutualUsers();
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

  void _navigateToChatScreen(
      String userId, String receiverName) async {

    final sharedPrefs = await SharedPreferences.getInstance();
    final userSessionService =
        UserSessionService(prefs: sharedPrefs);

    final myId = userSessionService.getUserId();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: userId,
          receiverName: receiverName,
          myId: myId!,
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
                  onTap: () => _navigateToChatScreen(
                    user['_id'],
                    user['name'],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "${ApiEndpoints.serverUrl}/uploads/${user['profilePicture']}",
                    ),
                  ),
                  title: Text(user['name']),
                );
              },
            ),
    );
  }
}