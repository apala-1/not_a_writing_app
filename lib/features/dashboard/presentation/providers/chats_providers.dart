import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:not_a_writing_app/core/api/api_client.dart';
import 'package:not_a_writing_app/features/dashboard/data/datasources/remote/chat_remote_datasource.dart';
import 'package:not_a_writing_app/features/dashboard/data/repositories/chat_repository.dart';
import 'package:not_a_writing_app/features/dashboard/domain/repositories/chat_repository.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/state/chat_state.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/chat_viewmodel.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/chat_vm_args.dart';
import 'package:not_a_writing_app/features/dashboard/presentation/view_model/conversations_viewmodel.dart';

final chatsRemoteDataSourceProvider = Provider<ChatsRemoteDataSource>((ref) {
  final api = ref.read(apiClientProvider);
  return ChatsRemoteDataSourceImpl(api);
});

final chatsRepositoryProvider = Provider<ChatsRepository>((ref) {
  return ChatsRepositoryImpl(ref.read(chatsRemoteDataSourceProvider));
});

// Conversations list VM
final conversationsVmProvider = StateNotifierProvider<ConversationsVm, ConversationsState>((ref) {
  return ConversationsVm(ref.read(chatsRepositoryProvider))..load();
});

// Chat (per conversation) VM
final chatVmProvider = StateNotifierProvider.family<ChatVm, ChatState, ChatVmArgs>((ref, args) {
  return ChatVm(repo: ref.read(chatsRepositoryProvider), args: args)..load();
});