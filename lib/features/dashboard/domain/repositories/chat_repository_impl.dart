import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Future<List<ChatEntity>> getMessages(String myId, String receiverId, String token) async {
    final raw = await remote.getMessages(myId, receiverId, token);

    // Map backend fields to your entity fields
    return raw.map((json) {
      return ChatEntity(
        id: json['_id'],
        sender: json['senderId'],
        receiver: json['receiverId'],
        message: json['content'],          // << important: content → message
        createdAt: DateTime.parse(json['createdAt']),
      );
    }).toList();
  }

  @override
  Future<void> sendMessage(String sender, String receiver, String message, String token) async {
    await remote.sendMessage(sender, receiver, message, token);
  }

  @override
  Stream<ChatEntity> onMessageReceived() {
    return remote.onMessageReceived().map((json) {
      return ChatEntity(
        id: json['_id'],
        sender: json['senderId'],
        receiver: json['receiverId'],
        message: json['content'],          // << same mapping here
        createdAt: DateTime.parse(json['createdAt']),
      );
    });
  }

  @override
  Future<void> connect(String myId, String token) => remote.connect(myId, token);

  @override
  void disconnect() => remote.disconnect();
}