import 'dart:io';
import 'package:dio/dio.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/chat_api_model.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/conversation_api_model.dart';

abstract class ChatsRemoteDataSource {
  Future<List<ConversationApiModel>> getMyConversations();
  Future<List<ChatApiModel>> getConversation(String userA, String userB);

  Future<ChatApiModel> sendText({required String receiverId, required String message});
  Future<ChatApiModel> sendImage({required String receiverId, required File file});

  Future<ChatApiModel> editMessage({required String messageId, required String content});
  Future<void> deleteMessage(String messageId);

  Future<void> markAsRead({required String senderId});
}

class ChatsRemoteDataSourceImpl implements ChatsRemoteDataSource {
  final ApiClient api;
  ChatsRemoteDataSourceImpl(this.api);

  dynamic _unwrap(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) return body['data'];
    return body;
  }

  @override
  Future<List<ConversationApiModel>> getMyConversations() async {
    final res = await api.dio.get(ApiEndpoints.getConversations());
    final data = _unwrap(res);
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(ConversationApiModel.fromJson).toList();
  }

  @override
  Future<List<ChatApiModel>> getConversation(String userA, String userB) async {
    final res = await api.dio.get(ApiEndpoints.getConversation(userA, userB));
    final data = _unwrap(res);
    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(ChatApiModel.fromJson).toList();
  }

  @override
  Future<ChatApiModel> sendText({required String receiverId, required String message}) async {
    final form = FormData.fromMap({
      'receiverId': receiverId,
      'message': message,
    });

    final res = await api.dio.post(
      ApiEndpoints.sendChat(),
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = _unwrap(res) as Map<String, dynamic>;
    return ChatApiModel.fromJson(data);
  }

  @override
  Future<ChatApiModel> sendImage({required String receiverId, required File file}) async {
    final form = FormData.fromMap({
      'receiverId': receiverId,
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });

    final res = await api.dio.post(
      ApiEndpoints.sendChat(),
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = _unwrap(res) as Map<String, dynamic>;
    return ChatApiModel.fromJson(data);
  }

  @override
  Future<ChatApiModel> editMessage({required String messageId, required String content}) async {
    final res = await api.dio.put(
      ApiEndpoints.editChat(messageId),
      data: {'content': content},
    );
    final data = _unwrap(res) as Map<String, dynamic>;
    return ChatApiModel.fromJson(data);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await api.dio.delete(ApiEndpoints.deleteChat(messageId));
  }

  @override
  Future<void> markAsRead({required String senderId}) async {
    await api.dio.post(ApiEndpoints.markChatAsRead(), data: {'senderId': senderId});
  }
}