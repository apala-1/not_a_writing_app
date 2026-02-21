// lib/features/chat/presentation/pages/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/storage/user_session_service.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverId;
  final String receiverName;
  final String myId;

  const ChatScreen({
    required this.receiverId,
    required this.receiverName,
    required this.myId,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

 @override
void initState() {
  super.initState();

  final userService = ref.read(userSessionServiceProvider);
  final token = userService.getUserToken() ?? '';

  // Delay until after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(chatViewModelProvider.notifier)
       .initialize(widget.myId, widget.receiverId);
  });
}

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      final msg = vm.messages[vm.messages.length - 1 - index];
                      final isMe = msg.sender == widget.myId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.message,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;
                    ref.read(chatViewModelProvider.notifier).sendMessage(
                          widget.myId,
                          widget.receiverId,
                          _controller.text.trim(),
                        );
                    _controller.clear();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}