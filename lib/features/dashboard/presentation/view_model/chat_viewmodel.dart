// lib/features/chat/presentation/viewmodel/chat_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/chat_repository.dart';
import '../../domain/entities/chat_entity.dart';

// State class
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

// ChatViewModel now extends StateNotifier
class ChatViewModel extends StateNotifier<ChatState> {
  final ChatRepository repository;

  ChatViewModel(this.repository) : super(ChatState(messages: [], loading: false));

  Future<void> loadMessages(String myId, String receiverId) async {
    state = state.copyWith(loading: true);
    final msgs = await repository.getMessages(myId, receiverId);
    state = state.copyWith(messages: msgs, loading: false);
  }

  Future<void> sendMessage(String sender, String receiver, String message) async {
    // Optimistic update
    final temp = ChatEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      receiver: receiver,
      message: message,
      createdAt: DateTime.now(),
      read: false,
    );
    state = state.copyWith(messages: [...state.messages, temp]);

    await repository.sendMessage(sender, receiver, message);
  }
}

// PROVIDER
final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final repository = ref.read(chatRepositoryProvider);
  return ChatViewModel(repository);
});