import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/services/socket/chat_socket_service.dart';

final chatSocketProvider = Provider<ChatSocketService>((ref) {
  final s = ChatSocketService();
  ref.onDispose(() => s.disconnect());
  return s;
});