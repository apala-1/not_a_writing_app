import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  // Theme Colors
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color bgColor = Color(0xFFFFF7ED);
  static const Color inputBg = Color(0xFFF9FAFB);

  @override
  void dispose() {
    scrollCtrl.dispose();
    ctrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool forceJump = false}) {
    if (!mounted) return;
    void go() {
      if (!mounted || !scrollCtrl.hasClients) return;
      final target = scrollCtrl.position.maxScrollExtent;
      if (forceJump) {
        scrollCtrl.jumpTo(target);
      } else {
        scrollCtrl.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => go());
    Future.delayed(const Duration(milliseconds: 100), go);
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
        if (next.messages.length != (prev?.messages.length ?? 0)) {
          _scrollToBottom(forceJump: (prev?.messages.length ?? 0) == 0);
        }
      });
    }

    final state = ref.watch(chatVmProvider(args));
    final vm = ref.read(chatVmProvider(args).notifier);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background Blobs for depth
          Positioned(top: 100, right: -50, child: _buildBlob(200, orangePrimary.withOpacity(0.08))),
          Positioned(bottom: 100, left: -50, child: _buildBlob(250, rosePrimary.withOpacity(0.08))),
          
          Column(
            children: [
              if (state.error != null) _buildErrorBanner(state.error!, vm),
              
              Expanded(
                child: state.loading
                    ? const Center(child: CircularProgressIndicator(color: orangePrimary))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                        controller: scrollCtrl,
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) => _buildMessageBubble(state.messages[i], vm),
                      ),
              ),
              
              _buildInputArea(vm),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.7),
      elevation: 0,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.transparent))),
      leading: const BackButton(color: Colors.black87),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: orangePrimary.withOpacity(0.2),
            child: Text(widget.otherName[0].toUpperCase(), style: const TextStyle(color: orangePrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Text(widget.otherName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic m, dynamic vm) {
    final isMe = m.senderId == widget.myUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _showOptions(m, vm) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            gradient: isMe ? const LinearGradient(colors: [orangePrimary, rosePrimary], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            color: isMe ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: m.type == 'image'
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_fullUrl(m.content), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(LucideIcons.imageOff)),
                )
              : Text(
                  m.content,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, fontWeight: isMe ? FontWeight.w500 : FontWeight.normal),
                ),
        ),
      ),
    );
  }

  Widget _buildInputArea(dynamic vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.image, color: orangePrimary),
            onPressed: () async {
              final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
              if (x != null) await vm.sendImage(File(x.path));
            },
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: orangePrimary)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              ctrl.clear();
              await vm.sendText(t);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [orangePrimary, rosePrimary])),
              child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)));
  }

  Widget _buildErrorBanner(String error, dynamic vm) {
    return Container(
      width: double.infinity,
      color: Colors.redAccent.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [Expanded(child: Text(error, style: const TextStyle(color: Colors.redAccent))), TextButton(onPressed: () => vm.load(), child: const Text("Retry"))]),
    );
  }

  void _showOptions(dynamic m, dynamic vm) async {
    final v = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(leading: const Icon(LucideIcons.penLine400), title: const Text('Edit Message'), onTap: () => Navigator.pop(context, 'edit')),
            ListTile(leading: const Icon(LucideIcons.trash2, color: Colors.redAccent), title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)), onTap: () => Navigator.pop(context, 'delete')),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (v == 'delete') {
      await vm.deleteMessage(m.id);
    } else if (v == 'edit' && m.type == 'text') {
      _showEditDialog(m, vm);
    }
  }

  void _showEditDialog(dynamic m, dynamic vm) async {
    final editCtrl = TextEditingController(text: m.content);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit message'),
        content: TextField(controller: editCtrl, autofocus: true, decoration: const InputDecoration(hintText: "Enter message...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: orangePrimary),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) await vm.editMessage(m.id, editCtrl.text);
  }
}