import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';

class ChatState {
  final List<ChatEntity> messages;
  final bool loading;

  ChatState({required this.messages, required this.loading});

  ChatState copyWith({List<ChatEntity>? messages, bool? loading}) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}