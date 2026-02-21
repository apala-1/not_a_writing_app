import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/core/services/storage/follow_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/widgets/follow_button.dart';

class FollowersPage extends ConsumerStatefulWidget {
  final String userId;

  const FollowersPage({super.key, required this.userId});

  @override
  ConsumerState<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends ConsumerState<FollowersPage> {
  late final FollowService service;
  List followers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final apiClient = ref.read(apiClientProvider); // get the actual ApiClient
    service = FollowService(apiClient.dio);        // pass its dio
    loadFollowers();
  }

  Future<void> loadFollowers() async {
    final data = await service.getFollowers(widget.userId);

    setState(() {
      followers = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final user = followers[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              "${ApiEndpoints.baseUrl}/uploads/${user['profilePicture']}",
            ),
          ),
          title: Text(user['name']),
          subtitle: Text(user['bio'] ?? ""),
          trailing: FollowButton(
            userId: user['_id'],
            service: service,
          ),
        );
      },
    );
  }
}