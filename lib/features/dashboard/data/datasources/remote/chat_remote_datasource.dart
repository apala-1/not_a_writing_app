import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_a_writing_app/core/api/api_endpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Provide a Dio instance (you can also configure base options here)
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Provide ChatRemoteDataSource as a singleton
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return ChatRemoteDataSource(dio);
});

class ChatRemoteDataSource {
  final Dio dio;
  late IO.Socket socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  ChatRemoteDataSource(this.dio);

  /// Fetch chat history from backend
  Future<List<Map<String, dynamic>>> getMessages(
      String myId, String receiverId, String token) async {
        print('${ApiEndpoints.baseUrl}${ApiEndpoints.getConversation(myId, receiverId)}');
    final res = await dio.get(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.getConversation(myId, receiverId)}',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    print('Res data: ${res.data}');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  /// Send message to backend
  Future<void> sendMessage(
    String sender, String receiver, String message, String token) async {
  if (token.isEmpty) {
    print('No token found! Cannot send message');
    return;
  }

  final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.sendMessage()}';
  print('Sending message to $url with token: $token');

  await dio.post(
    url,
    data: {'receiverId': receiver, 'message': message},
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
}

  /// Socket: connect for real-time updates
  Future<void> connect(String myId, String token) async {
    socket = IO.io(
      ApiEndpoints.baseUrl.replaceFirst('http', 'ws'), // ws:// or wss://
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token, 'userId': myId})
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print('Socket connected'));
    socket.on('receive_message', (data) {
      _controller.add(Map<String, dynamic>.from(data));
    });
    socket.onDisconnect((_) => print('Socket disconnected'));
  }

  /// Stream to listen for incoming messages
  Stream<Map<String, dynamic>> onMessageReceived() => _controller.stream;

  /// Disconnect socket
  void disconnect() {
    socket.dispose();
    _controller.close();
  }
}