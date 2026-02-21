// lib/features/chat/data/repositories/chat_repository_impl.dart
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/chat_repository.dart';

import '../../domain/entities/chat_entity.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChatEntity>> getMessages(String myId, String receiverId) async {
    final raw = await remoteDataSource.getMessages(myId, receiverId);
    return raw.map((e) => ChatEntity.fromJson(e)).toList();
  }

  @override
  Future<void> sendMessage(String sender, String receiver, String message) async {
    await remoteDataSource.sendMessage(sender, receiver, message);
  }
}