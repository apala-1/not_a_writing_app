import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';

final chatRemoteDataSourceProvider =
    Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.read(apiClientProvider));
});

class ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSource(this.apiClient);

  /// ✅ GET conversation between two users
  Future<List<dynamic>> getMessages(
      String myId, String receiverId) async {
    final response = await apiClient.get(
      "${ApiEndpoints.baseUrl}"
      "${ApiEndpoints.getConversation(myId, receiverId)}",
    );

    return response.data['data'] ?? [];
  }

  /// ✅ SEND message
  Future<void> sendMessage(
      String sender,
      String receiver,
      String message,
      ) async {
    await apiClient.post(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.sendMessage()}",
      data: {
        "sender": sender,
        "receiver": receiver,
        "message": message,
      },
    );
  }
}