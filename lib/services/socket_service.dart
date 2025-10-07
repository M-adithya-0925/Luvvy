import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  static SocketService get instance => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool isConnected = false;
  String? _currentUserEmail;

  // Callbacks
  Function(Map<String, dynamic>)? onLikeReceived;
  Function(Map<String, dynamic>)? onMatchCreated;
  Function(String)? onError;
  Function(Map<String, dynamic>)? onNewMessage;
  Function(bool)? onConnectionChanged;

  void connect(String userEmail) {
    _currentUserEmail = userEmail;

    print('🔌 Attempting Socket.IO connection to Flask server...');

    // 🆕 Enhanced configuration for Android compatibility
    _socket = IO.io('http://192.168.1.27:5000', {
      'transports': ['websocket', 'polling'], // 🆕 Try both transports
      'autoConnect': false,
      'timeout': 10000, // 🆕 10 second timeout
      'forceNew': true, // 🆕 Force new connection
      'upgrade': true,  // 🆕 Allow transport upgrade
    });

    _socket?.connect();

    // Connection success
    _socket?.on('connect', (_) {
      print('✅ Socket.IO connected successfully!');
      print('📡 Socket ID: ${_socket?.id}');
      isConnected = true;
      onConnectionChanged?.call(true);

      // Register user with Flask backend
      _socket?.emit('user_online', {'email': userEmail});
      print('👤 Registered user online: $userEmail');
    });

    // Connection failure
    _socket?.on('connect_error', (error) {
      print('❌ Socket.IO connection error: $error');
      isConnected = false;
      onConnectionChanged?.call(false);
      onError?.call('Connection failed: $error');
    });

    // Connection timeout
    _socket?.on('connect_timeout', (timeout) {
      print('⏰ Socket.IO connection timeout: $timeout');
      onError?.call('Connection timeout - server may be unreachable');
    });

    // Disconnection
    _socket?.on('disconnect', (reason) {
      print('❌ Socket.IO disconnected: $reason');
      isConnected = false;
      onConnectionChanged?.call(false);
    });

    // 🆕 Backend response handlers
    _socket?.on('new_like', (data) {
      print('💖 Received like from backend: $data');
      if (onLikeReceived != null) {
        onLikeReceived!(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('new_match', (data) {
      print('🎉 Received match from backend: $data');
      if (onMatchCreated != null) {
        onMatchCreated!(Map<String, dynamic>.from(data));
      }
    });

    _socket?.on('like_sent', (data) {
      print('✅ Like confirmed by backend: $data');
    });

    _socket?.on('error', (error) {
      print('❌ Backend error: $error');
      if (onError != null) {
        onError!(error.toString());
      }
    });

    // 🆕 Add connection retry logic
    Future.delayed(Duration(seconds: 5), () {
      if (!isConnected) {
        print('⚠️ Socket.IO connection failed after 5 seconds');
        onError?.call('Unable to connect to server. Please check your network.');
      }
    });
  }

  void likeUser(String likedUserEmail, {double matchScore = 85.0}) {
    print('👍 Attempting to like user: $likedUserEmail');
    print('🔗 Socket connected: ${_socket?.connected}');
    print('📡 Socket ID: ${_socket?.id}');

    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('like_user', {
        'liker_email': _currentUserEmail,
        'liked_email': likedUserEmail,
        'match_score': matchScore,
      });
      print('📤 Like sent via Socket.IO to Flask backend');
    } else {
      print('❌ Cannot send like - not connected to backend');
      print('   - Socket exists: ${_socket != null}');
      print('   - Socket connected: ${_socket?.connected}');
      print('   - Current user: $_currentUserEmail');
      onError?.call('Not connected to backend. Like not sent.');
    }
  }
// Add this method to your SocketService class if it's missing
  void sendMessage(String receiverEmail, String message, {String? chatId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('send_message', {
        'senderEmail': _currentUserEmail,
        'receiverEmail': receiverEmail,
        'message': message,
        'chatId': chatId,
      });
      print('📤 Message sent via Socket.IO: $message');
    } else {
      print('❌ Cannot send message - not connected to backend');
      onError?.call('Not connected to send message');
    }
  }

  void acceptLike(String originalLikerEmail, {String? notificationId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('accept_like', {
        'accepter_email': _currentUserEmail,
        'original_liker_email': originalLikerEmail,
        'notification_id': notificationId ?? '',
      });
      print('✅ Accept like sent to backend');
    } else {
      onError?.call('Not connected to accept like');
    }
  }

  void rejectLike(String originalLikerEmail, {String? notificationId}) {
    if (_socket?.connected == true && _currentUserEmail != null) {
      _socket?.emit('reject_like', {
        'rejector_email': _currentUserEmail,
        'original_liker_email': originalLikerEmail,
        'notification_id': notificationId ?? '',
      });
      print('❌ Reject like sent to backend');
    } else {
      onError?.call('Not connected to reject like');
    }
  }

  void disconnect() {
    print('🔌 Disconnecting Socket.IO...');
    _socket?.disconnect();
    _socket?.dispose();
    isConnected = false;
    _currentUserEmail = null;

    // Clear callbacks
    onLikeReceived = null;
    onMatchCreated = null;
    onError = null;
    onNewMessage = null;
    onConnectionChanged = null;
  }
}
