import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationsState {
  final bool loading;
  final String? error;
  final List<ConversationEntity> conversations;

  const ConversationsState({required this.loading, required this.conversations, this.error});
  factory ConversationsState.initial() => const ConversationsState(loading: false, conversations: []);
  ConversationsState copyWith({bool? loading, String? error, List<ConversationEntity>? conversations}) {
    return ConversationsState(
      loading: loading ?? this.loading,
      error: error,
      conversations: conversations ?? this.conversations,
    );
  }
}

class ConversationsVm extends StateNotifier<ConversationsState> {
  final ChatsRepository repo;
  ConversationsVm(this.repo) : super(ConversationsState.initial());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await repo.getMyConversations();
      state = state.copyWith(loading: false, conversations: data);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}