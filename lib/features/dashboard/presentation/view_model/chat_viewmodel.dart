import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/domain/entities/chat_entity.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository_impl.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/chat_state.dart';
import 'package:uuid/uuid.dart';

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final repo = ChatRepositoryImpl(ref.read(chatRemoteDataSourceProvider));
  final token = ref.read(userSessionServiceProvider).getUserToken() ?? '';
  final senderId = ref.read(userSessionServiceProvider).getUserId() ?? 'unknown';
  return ChatViewModel(repo, token);
});

class ChatViewModel extends StateNotifier<ChatState> {
  final ChatRepositoryImpl repo;
  final String token;
  
  StreamSubscription<ChatEntity>? _sub;

  ChatViewModel(this.repo, this.token) : super(ChatState(messages: [], loading: false));

  Future<void> initialize(String myId, String receiverId) async {
    // Connect socket
    await repo.connect(myId, token);
    print('{myId: $myId, token: $token}');

    // Fetch history
    state = state.copyWith(loading: true);
    final history = await repo.getMessages(myId, receiverId, token);
    state = state.copyWith(messages: history, loading: false);

    // Listen for new messages
    _sub = repo.onMessageReceived().listen((message) {
      state = state.copyWith(messages: [...state.messages, message]);
    });
  }

void sendMessage(String sender, String receiver, String message) async {
  // Create local ChatEntity
  final newMessage = ChatEntity(
    id: const Uuid().v4(),
    sender: sender,
    receiver: receiver,
    message: message,
    createdAt: DateTime.now(),
  );
  print('Sender in vm: $sender, Receiver: $receiver, Message: $message , Token: $token');

  // Add it to state so UI updates immediately
  state = state.copyWith(messages: [...state.messages, newMessage]);

  try {
    await repo.sendMessage(sender, receiver, message, token);
  } catch (e) {
    print('Error sending message: $e');
  }
}

  @override
  void dispose() {
    _sub?.cancel();
    repo.disconnect();
    super.dispose();
  }
}