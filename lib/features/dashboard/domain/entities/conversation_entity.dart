class ConversationEntity {
  final String otherUserId;
  final String name;
  final String? profilePicture; // likely "/uploads/.."
  final String? lastMessage;
  final DateTime? lastTime;

  const ConversationEntity({
    required this.otherUserId,
    required this.name,
    required this.profilePicture,
    required this.lastMessage,
    required this.lastTime,
  });
}