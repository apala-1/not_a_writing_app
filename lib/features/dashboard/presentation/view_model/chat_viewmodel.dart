import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/data/models/chat_api_model.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/chat_state.dart';
import '../../domain/entities/chat_entity.dart';
import 'chat_vm_args.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class ChatVm extends StateNotifier<ChatState> {
  final ChatsRepository repo;
  final ChatVmArgs args;
  IO.Socket? _socket;

  ChatVm({required this.repo, required this.args}) : super(ChatState.initial());

 Future<void> load() async {
  state = state.copyWith(loading: true, error: null);

  try {
    final data = await repo.getConversation(args.myUserId, args.otherUserId);

    // ✅ stop spinner as soon as messages are fetched
    state = state.copyWith(loading: false, messages: data);

    // ✅ mark-as-read should NOT block UI
    try {
      await repo.markAsRead(senderId: args.otherUserId);
    } catch (_) {
      // ignore or log; don't re-enter loading
    }
  } catch (e) {
    state = state.copyWith(loading: false, error: e.toString());
  }
}

 Future<void> sendText(String text) async {
  if (text.trim().isEmpty) return;
  try {
    await repo.sendText(receiverId: args.otherUserId, message: text.trim());
    // ✅ don't append here, socket will bring it (or reload)
    await load(); // optional fallback if socket doesn't arrive
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}

Future<void> sendImage(File file) async {
  try {
    await repo.sendImage(receiverId: args.otherUserId, file: file);
    // ✅ don't append here
    await load(); // optional fallback
  } catch (e) {
    state = state.copyWith(error: e.toString());
  }
}


void attachSocket(IO.Socket socket) {
  _socket = socket;

  socket.off('chat:new');
  socket.off('chat:edited');
  socket.off('chat:deleted');

  socket.on('chat:new', (data) {
    // data is a map (json) from backend
    final msg = ChatApiModel.fromJson(Map<String, dynamic>.from(data)).toEntity();

    final isThisConversation =
        (msg.senderId == args.myUserId && msg.receiverId == args.otherUserId) ||
        (msg.senderId == args.otherUserId && msg.receiverId == args.myUserId);

    if (!isThisConversation) return;
    if (state.messages.any((m) => m.id == msg.id)) return;

   state = state.copyWith(messages: [...state.messages, msg]);
  });

  socket.on('chat:edited', (data) {
    final msg = ChatApiModel.fromJson(Map<String, dynamic>.from(data)).toEntity();
    state = state.copyWith(
      messages: state.messages.map((m) => m.id == msg.id ? msg : m).toList(),
    );
  });

  socket.on('chat:deleted', (data) {
    final id = (data as Map)['id'].toString();
    state = state.copyWith(messages: state.messages.where((m) => m.id != id).toList());
  });
}

  Future<void> editMessage(String id, String content) async {
    try {
      final updated = await repo.editMessage(messageId: id, content: content);
      final next = state.messages.map((m) => m.id == id ? updated : m).toList();
      state = state.copyWith(messages: next);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await repo.deleteMessage(id);
      state = state.copyWith(messages: state.messages.where((m) => m.id != id).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}