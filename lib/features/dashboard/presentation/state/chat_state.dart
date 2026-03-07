import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';

class ChatState {
  final bool loading;
  final String? error;
  final List<ChatEntity> messages;

  const ChatState({required this.loading, required this.messages, this.error});
  factory ChatState.initial() => const ChatState(loading: false, messages: []);
  ChatState copyWith({
  bool? loading,
  String? error,
  List<ChatEntity>? messages,
}) {
  return ChatState(
    loading: loading ?? this.loading,
    error: error,
    messages: messages ?? this.messages,
  );
}
}