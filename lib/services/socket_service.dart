import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  static SocketService get instance => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool isConnected = false;
  String? _currentUserEmail;

  // 🆕 ALL the callbacks your MainPage expects
  Function(Map<String, dynamic>)? onLikeReceived;
  Function(Map<String, dynamic>)? onMatchCreated;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onNewMessage;
  Function(bool)? onConnectionChanged;

  void connect(String userEmail) {
    _currentUserEmail = userEmail;

    // Replace with your Flask server IP
    _socket = IO.io('http://192.168.1.27:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.connect();

    _socket?.on('connect', (_) {
      print('🔗 Connected to Flask server');
      isConnected = true;
      onConnectionChanged?.call(true);

      // Register user as online
      _socket?.emit('user_online', {'email': userEmail});
    });

    _socket?.on('disconnect', (_) {
      print('❌ Disconnected from Flask server');
      isConnected = false;
      onConnectionChanged?.call(false);
    });

    _socket?.on('connect_error', (error) {
      print('❌ Connection error: $error');
      onError?.call('Connection failed: $error');
    });

    // 🆕 Listen for new likes (matches your MainPage expectations)
    _socket?.on('new_like', (data) {
      print('💖 New like received: $data');
      if (onLikeReceived != null) {
        onLikeReceived!(Map<String, dynamic>.from(data));
      }
    });

    // 🆕 Listen for new matches
    _socket?.on('new_match', (data) {
      print('🎉 New match created: $data');
      if (onMatchCreated != null) {
        onMatchCreated!(Map<String, dynamic>.from(data));
      }
    });

    // Listen for new messages
    _socket?.on('new_message', (data) {
      print('📨 New message received: $data');
      if (onNewMessage != null) {
        onNewMessage!(Map<String, dynamic>.from(data));
      }
    });

    // Listen for errors
    _socket?.on('error', (error) {
      print('❌ Socket error: $error');
      if (onError != null) {
        onError!(error.toString());
      }
    });
  }

  // 🆕 Like user method (called from MainPage)
  void likeUser(String likedUserEmail, {double matchScore = 85.0}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('like_user', {
        'liker_email': _currentUserEmail,
        'liked_email': likedUserEmail,
        'match_score': matchScore,
      });
      print('👍 Sent like to $likedUserEmail');
    } else {
      onError?.call('Not connected to send like');
    }
  }

  // 🆕 Accept like method (called from MainPage)
  void acceptLike(String originalLikerEmail, {String? notificationId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('accept_like', {
        'accepter_email': _currentUserEmail,
        'original_liker_email': originalLikerEmail,
        'notification_id': notificationId ?? '',
      });
      print('✅ Accepted like from $originalLikerEmail');
    } else {
      onError?.call('Not connected to accept like');
    }
  }

  // 🆕 Reject like method (called from MainPage)
  void rejectLike(String originalLikerEmail, {String? notificationId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('reject_like', {
        'rejector_email': _currentUserEmail,
        'original_liker_email': originalLikerEmail,
        'notification_id': notificationId ?? '',
      });
      print('❌ Rejected like from $originalLikerEmail');
    } else {
      onError?.call('Not connected to reject like');
    }
  }

  // Send message method
  void sendMessage(String receiverEmail, String message, {String? chatId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('send_message', {
        'senderEmail': _currentUserEmail,
        'receiverEmail': receiverEmail,
        'message': message,
        'chatId': chatId,
      });
      print('📤 Message sent to $receiverEmail: $message');
    } else {
      onError?.call('Not connected to send message');
    }
  }

  // Join chat room
  void joinChat(String userEmail, String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('join_chat', {
        'userEmail': userEmail,
        'chatId': chatId,
      });
      print('💬 Joined chat: $chatId');
    }
  }

  // Mark messages as read
  void markMessagesRead(String chatId) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('mark_messages_read', {
        'chatId': chatId,
        'userEmail': _currentUserEmail,
      });
    }
  }

  // Disconnect
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    isConnected = false;
    _currentUserEmail = null;

    // Clear all callbacks
    onLikeReceived = null;
    onMatchCreated = null;
    onError = null;
    onNewMessage = null;
    onConnectionChanged = null;
  }
}
