import 'package:uuid/uuid.dart';

class ChatEntity {
  final String id;
  final String sender;
  final String receiver;
  final String message;
  final DateTime createdAt;

  ChatEntity({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.createdAt,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
  return ChatEntity(
    id: json['_id'] ?? const Uuid().v4(),
    sender: json['senderId'] ?? '',
    receiver: json['receiverId'] ?? '',
    message: json['message'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
  );
}
}