import 'dart:io';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/conversation_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final ChatsRemoteDataSource remote;
  ChatsRepositoryImpl(this.remote);

  @override
  Future<List<ConversationEntity>> getMyConversations() async {
    final models = await remote.getMyConversations();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ChatEntity>> getConversation(String userA, String userB) async {
    final models = await remote.getConversation(userA, userB);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ChatEntity> sendText({required String receiverId, required String message}) async {
    final m = await remote.sendText(receiverId: receiverId, message: message);
    return m.toEntity();
  }

  @override
  Future<ChatEntity> sendImage({required String receiverId, required File file}) async {
    final m = await remote.sendImage(receiverId: receiverId, file: file);
    return m.toEntity();
  }

  @override
  Future<ChatEntity> editMessage({required String messageId, required String content}) async {
    final m = await remote.editMessage(messageId: messageId, content: content);
    return m.toEntity();
  }

  @override
  Future<void> deleteMessage(String messageId) => remote.deleteMessage(messageId);

  @override
  Future<void> markAsRead({required String senderId}) => remote.markAsRead(senderId: senderId);
}