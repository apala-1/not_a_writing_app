import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:not_a_writing_app/core/api/api_endpoints.dart';

class ChatSocketService {
  IO.Socket? _socket;

  IO.Socket connect({required String userId}) {
    _socket ??= IO.io(
      ApiEndpoints.serverUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    if (!_socket!.connected) {
      _socket!.connect();
    }

    _socket!.onConnect((_) {
      _socket!.emit('join', userId);
    });

    _socket!.onConnectError((data) {
      // helpful logs
      // ignore: avoid_print
      print('socket connect error: $data');
    });

    _socket!.onError((data) {
      // ignore: avoid_print
      print('socket error: $data');
    });

    return _socket!;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}