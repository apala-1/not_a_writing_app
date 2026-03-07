import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/chat_socket_provider.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/providers/chats_providers.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/chat_vm_args.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String myUserId;
  final String otherUserId;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.myUserId,
    required this.otherUserId,
    required this.otherName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ctrl = TextEditingController();
  final picker = ImagePicker();
  final scrollCtrl = ScrollController();

  bool _didSetupListen = false;

  @override
  void dispose() {
    scrollCtrl.dispose();
    ctrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool forceJump = false}) {
  if (!mounted) return;

  void go() {
    if (!mounted) return;
    if (!scrollCtrl.hasClients) return;
    print('hasClients=${scrollCtrl.hasClients} max=${scrollCtrl.position.maxScrollExtent} pixels=${scrollCtrl.position.pixels}');

    final target = scrollCtrl.position.maxScrollExtent;
    if (forceJump) {
      scrollCtrl.jumpTo(target);
    } else {
      scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // 1) next frame (after rebuild)
  WidgetsBinding.instance.addPostFrameCallback((_) => go());

  // 2) tiny delay helps when images affect layout
  Future.delayed(const Duration(milliseconds: 60), go);
}

  String _fullUrl(String v) {
    if (v.startsWith('http')) return v;
    if (v.startsWith('/uploads/')) return '${ApiEndpoints.serverUrl}$v';
    return v;
  }


  @override
  Widget build(BuildContext context) {
    final args = ChatVmArgs(myUserId: widget.myUserId, otherUserId: widget.otherUserId);
    if (!_didSetupListen) {
    _didSetupListen = true;
    ref.listen(chatVmProvider(args), (prev, next) {
      final prevLen = prev?.messages.length ?? 0;
      if (next.messages.length != prevLen) {
        _scrollToBottom(forceJump: prevLen == 0); // jump on first load
      }
    });
  }
    final state = ref.watch(chatVmProvider(args));
    final vm = ref.read(chatVmProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherName)),
      body: Column(
        children: [
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              actions: [TextButton(onPressed: () => vm.load(), child: const Text('Retry'))],
            ),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    controller: scrollCtrl,
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) {
                      final m = state.messages[i];
                      final isMe = m.senderId == widget.myUserId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: isMe
                              ? () async {
                                  final v = await showModalBottomSheet<String>(
                                    context: context,
                                    builder: (_) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text('Edit'),
                                            onTap: () => Navigator.pop(context, 'edit'),
                                          ),
                                          ListTile(
                                            title: const Text('Delete'),
                                            onTap: () => Navigator.pop(context, 'delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                                  if (v == 'delete') {
                                    await vm.deleteMessage(m.id);
                                  } else if (v == 'edit' && m.type == 'text') {
                                    final editCtrl = TextEditingController(text: m.content);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Edit message'),
                                        content: TextField(controller: editCtrl),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await vm.editMessage(m.id, editCtrl.text);
                                  }
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: m.type == 'image'
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _fullUrl(m.content),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Text('Image failed to load'),
                                    ),
                                  )
                                : Text(m.content),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (x == null) return;
                    await vm.sendImage(File(x.path));
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(hintText: 'Message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final t = ctrl.text;
                    ctrl.clear();
                    await vm.sendText(t);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}