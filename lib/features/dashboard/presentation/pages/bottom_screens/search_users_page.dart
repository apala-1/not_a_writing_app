import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/follow_service.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/follow_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  late final ApiClient apiClient;
  late FollowService followService; // no initial value

  List users = [];
  bool loading = false;
  String query = "";

@override
void initState() {
  super.initState();
  initServices();
}

Future<void> initServices() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  final userSessionService = UserSessionService(prefs: sharedPrefs);
  apiClient = ApiClient(userSessionService);

  followService = FollowService(apiClient.dio); // ✅ legal
setState(() {});
}

  Future<void> search(String value) async {
    if (value.isEmpty) {
      setState(() => users = []);
      return;
    }

    setState(() => loading = true);

    final res = await apiClient.get(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.searchUsers(value)}",
    );

    setState(() {
      users = res.data['data'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Users")),
      body: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search writers...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                query = value;
                search(value);
              },
            ),
          ),

          // 📋 Results
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            "${ApiEndpoints.serverUrl}/uploads/${user['profilePicture']}",
                          ),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['bio'] ?? ""),
                        trailing: FollowButton(
                          userId: user['_id'],
                          service: followService,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}