import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';

class ChatApiModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String type;
  final String content;
  final bool read;
  final DateTime? createdAt;

  ChatApiModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  factory ChatApiModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString());
    return ChatApiModel(
      id: (json['_id'] ?? json['id']).toString(),
      senderId: json['senderId'].toString(),
      receiverId: json['receiverId'].toString(),
      type: (json['type'] ?? 'text').toString(),
      content: (json['content'] ?? '').toString(),
      read: (json['read'] ?? false) == true,
      createdAt: createdAt,
    );
  }

  ChatEntity toEntity() => ChatEntity(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        type: type,
        content: content,
        read: read,
        createdAt: createdAt,
      );
}