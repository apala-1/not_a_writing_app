// lib/features/chat/domain/entities/chat_entity.dart
class ChatEntity {
  final String id;
  final String sender;
  final String receiver;
  final String message;
  final DateTime createdAt;
  final bool read;

  ChatEntity({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return ChatEntity(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      read: json['read'] ?? false,
    );
  }
}