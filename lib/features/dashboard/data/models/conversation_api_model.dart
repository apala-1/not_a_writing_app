import 'package:not_a_writing_app/features/dashboard/domain/entities/conversation_entity.dart';

class ConversationApiModel {
  final String otherUserId;
  final String name;
  final String? profilePicture;
  final String? lastMessage;
  final DateTime? lastTime;

  ConversationApiModel({
    required this.otherUserId,
    required this.name,
    required this.profilePicture,
    required this.lastMessage,
    required this.lastTime,
  });

  factory ConversationApiModel.fromJson(Map<String, dynamic> json) {
    final lastTime = json['lastTime'] == null ? null : DateTime.tryParse(json['lastTime'].toString());
    return ConversationApiModel(
      otherUserId: json['_id'].toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      profilePicture: json['profilePicture']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastTime: lastTime,
    );
  }

  ConversationEntity toEntity() => ConversationEntity(
        otherUserId: otherUserId,
        name: name,
        profilePicture: profilePicture,
        lastMessage: lastMessage,
        lastTime: lastTime,
      );
}