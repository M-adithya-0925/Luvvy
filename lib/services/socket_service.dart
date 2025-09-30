import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  late IO.Socket socket;
  bool isConnected = false;

  // Event listeners
  void Function(dynamic)? onLikeReceived;
  void Function(dynamic)? onMatchCreated;
  void Function(dynamic)? onNewMessage;
  void Function(bool)? onConnectionChanged;
  void Function(String)? onError;

  void connect(String userEmail) {
    socket = IO.io('http://192.168.1.48:5000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({"username":userEmail}).build());
    socket.connect();

    socket.onConnect((_) {
      isConnected = true;
      if (onConnectionChanged != null) onConnectionChanged!(true);
    });
    socket.onDisconnect((_) {
      isConnected = false;
      if (onConnectionChanged != null) onConnectionChanged!(false);
    });
    socket.on('like_received', (data) {
      if (onLikeReceived != null) onLikeReceived!(data);
    });
    socket.on('match_created', (data) {
      if (onMatchCreated != null) onMatchCreated!(data);
    });
    socket.on('new_message', (data) {
      if (onNewMessage != null) onNewMessage!(data);
    });
    socket.on('error', (data) {
      if (onError != null) onError!(data is Map && data.containsKey("message")
          ? data["message"].toString()
          : data.toString());
    });
  }

  void sendMessage(String toUser, String message) {
    socket.emit('private_message', {"to":toUser,"message":message});
  }

  void acceptLike(String fromUser) {
    socket.emit('accept_like', {'from': fromUser});
  }

  void rejectLike(String fromUser) {
    socket.emit('reject_like', {'from': fromUser});
  }

  void likeUser(String toUser) {
    socket.emit('like_user', {'to': toUser});
  }
}
