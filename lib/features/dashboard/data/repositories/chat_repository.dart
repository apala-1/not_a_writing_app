import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> getMessages(String myId, String receiverId, String token);
  Future<void> sendMessage(String sender, String receiver, String message, String token);
  Stream<ChatEntity> onMessageReceived();
  Future<void> connect(String myId, String token);
  void disconnect();
}