// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository_impl.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // This provider would typically return an instance of ChatRepositoryImpl
  // For now, we're just returning a mock implementation for demonstration
  return ChatRepositoryImpl(ref.read(chatRemoteDataSourceProvider));
});

abstract class ChatRepository {
  Future<List<ChatEntity>> getMessages(String myId, String receiverId);
  Future<void> sendMessage(String sender, String receiver, String message);
}