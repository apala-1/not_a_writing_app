class ChatEntity {
  final String id;
  final String senderId;
  final String receiverId;

  final String type; // "text" | "image"
  final String content; // text or "/uploads/chats/.."
  final bool read;
  final DateTime? createdAt;

  const ChatEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  bool get isImage => type == 'image';
}