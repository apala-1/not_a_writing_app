import 'dart:io';
import '../entities/chat_entity.dart';
import '../entities/conversation_entity.dart';

abstract class ChatsRepository {
  Future<List<ConversationEntity>> getMyConversations();
  Future<List<ChatEntity>> getConversation(String userA, String userB);

  Future<ChatEntity> sendText({required String receiverId, required String message});
  Future<ChatEntity> sendImage({required String receiverId, required File file});

  Future<ChatEntity> editMessage({required String messageId, required String content});
  Future<void> deleteMessage(String messageId);

  Future<void> markAsRead({required String senderId});
}