import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/socket_service.dart';
import 'chat.dart';
import 'detailed_chat_screen.dart';
import 'interestspage.dart';
import 'terms_conditions.dart';
import 'dart:math' as math;

class MainPage extends StatefulWidget {
  final String userEmail;
  final List<dynamic> recommendations;

  const MainPage({
    Key? key,
    required this.userEmail,
    required this.recommendations,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final SocketService _socket = SocketService.instance;
  SwipableStackController _swipeController = SwipableStackController();

  // Backend configuration
  final String backendUrl = 'http://192.168.1.27:5000';

  Set<String> likedEmails = {};
  Set<String> matchedEmails = {};
  List<Map<String, dynamic>> pendingLikes = [];
  List<dynamic> filteredRecommendations = [];
  bool _isLoadingInteractions = true;
  bool _isBackendConnected = false;

  // Animations
  AnimationController? _fadeController;
  AnimationController? _buttonController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _buttonAnimation;

  @override
  void initState() {
    super.initState();

    print('🚀 MainPage initialized for user: ${widget.userEmail}');
    print('📊 Total recommendations: ${widget.recommendations.length}');

    // Initialize animations
    _initializeAnimations();

    // Test backend connectivity first
    _testBackendConnectivity();

    // Connect to Socket.IO
    _setupSocketConnection();

    // Load existing interactions
    _loadUserInteractions().then((_) {
      _filterRecommendations();
      _fadeController?.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        _buttonController?.forward();
      });
    });
  }

  // ===========================
  // BACKEND CONNECTIVITY
  // ===========================

  Future<void> _testBackendConnectivity() async {
    print('🔍 Testing backend connectivity...');
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Backend reachable via HTTP: ${response.body}');
        setState(() => _isBackendConnected = true);
      } else {
        print('❌ Backend HTTP error: ${response.statusCode}');
        setState(() => _isBackendConnected = false);
      }
    } catch (e) {
      print('❌ Backend connectivity test failed: $e');
      setState(() => _isBackendConnected = false);
      if (mounted) {
        _showErrorSnackBar('⚠️ Cannot reach server. Using offline mode.');
      }
    }
  }

  void _setupSocketConnection() {
    _socket.connect(widget.userEmail);

    // Connection status monitoring
    _socket.onConnectionChanged = (isConnected) {
      print(isConnected ? '🟢 MainPage: Connected to backend' : '🔴 MainPage: Disconnected from backend');
      setState(() => _isBackendConnected = isConnected);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
                SizedBox(width: 12),
                Text(isConnected ? '🟢 Connected to server' : '🔴 Connection lost'),
              ],
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    };

    // Socket listeners
    _socket.onLikeReceived = (data) {
      print('💖 MainPage received like: $data');
      final fromUser = data['from'] as String;
      if (!pendingLikes.any((e) => e['from'] == fromUser)) {
        setState(() => pendingLikes.add({'from': fromUser, 'data': data}));
      }
      _showLikeReceivedDialog(fromUser, data);
    };

    _socket.onMatchCreated = (data) {
      print('🎉 MainPage received match: $data');
      final matchedUser = data['with'] as String;
      setState(() {
        matchedEmails.add(matchedUser);
        likedEmails.add(matchedUser);
      });
      _filterRecommendations();
      _showMatchDialog(matchedUser, data);
    };

    _socket.onError = (msg) {
      print('❌ MainPage socket error: $msg');
      _showErrorSnackBar(msg);
    };
  }

  // ===========================
  // LIKE FUNCTIONALITY
  // ===========================

  Future<void> _likeUser(String likedUserEmail) async {
    print('👍 Attempting to like user: $likedUserEmail');

    // Add to local liked list immediately for UI responsiveness
    setState(() {
      likedEmails.add(likedUserEmail);
    });

    try {
      // Method 1: Try Socket.IO first (real-time)
      if (_socket.isConnected) {
        _socket.likeUser(likedUserEmail, matchScore: 85.0);
        print('📡 Like sent via Socket.IO');
        _showSuccessSnackBar('Like sent! 💖');
      } else {
        // Method 2: Fallback to HTTP API
        await _likeUserViaHTTP(likedUserEmail);
      }
    } catch (e) {
      print('❌ Error liking user: $e');
      _showErrorSnackBar('Failed to send like. Try again.');
    }
  }

  Future<void> _likeUserViaHTTP(String likedUserEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'liker_email': widget.userEmail,
          'liked_email': likedUserEmail,
          'match_score': 85.0,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ HTTP like successful: $data');
        _showSuccessSnackBar('Like sent! 💖');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ HTTP like failed: $e');
      _showErrorSnackBar('Failed to send like via HTTP');
    }
  }

  void _acceptLike(String fromUserEmail) {
    print('✅ Accepting like from: $fromUserEmail');

    if (_socket.isConnected) {
      _socket.acceptLike(fromUserEmail);
    } else {
      _acceptLikeViaHTTP(fromUserEmail);
    }
  }

  Future<void> _acceptLikeViaHTTP(String fromUserEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/accept_like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accepter_email': widget.userEmail,
          'original_liker_email': fromUserEmail,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ HTTP accept like successful: $data');

        if (data['mutual_match'] == true) {
          setState(() {
            matchedEmails.add(fromUserEmail);
            likedEmails.add(fromUserEmail);
          });
          _filterRecommendations();
          _showMatchDialog(fromUserEmail, {
            'matchId': data['match_id'],
            'chatId': data['match_id']?.replaceAll('match_', 'chat_')
          });
        }
      }
    } catch (e) {
      print('❌ Error accepting like via HTTP: $e');
    }
  }

  void _rejectLike(String fromUserEmail) {
    print('❌ Rejecting like from: $fromUserEmail');

    if (_socket.isConnected) {
      _socket.rejectLike(fromUserEmail);
    } else {
      _rejectLikeViaHTTP(fromUserEmail);
    }
  }

  Future<void> _rejectLikeViaHTTP(String fromUserEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/reject_like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rejector_email': widget.userEmail,
          'original_liker_email': fromUserEmail,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ HTTP reject like successful');
      }
    } catch (e) {
      print('❌ Error rejecting like via HTTP: $e');
    }
  }

  // ===========================
  // ANIMATIONS
  // ===========================

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController!, curve: Curves.elasticOut),
    );
  }

  // ===========================
  // DATA LOADING
  // ===========================

  Future<void> _loadUserInteractions() async {
    final user = widget.userEmail;
    try {
      final likesSnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('from', isEqualTo: user)
          .get();

      final matchesSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('users', arrayContains: user)
          .get();

      setState(() {
        likedEmails = likesSnapshot.docs.map((doc) {
          final data = doc.data();
          return data['to'] as String? ?? '';
        }).where((email) => email != '').toSet();

        matchedEmails = matchesSnapshot.docs.expand((doc) {
          final users = List<String>.from(doc.data()['users'] ?? []);
          return users.where((e) => e != user);
        }).toSet();

        _isLoadingInteractions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInteractions = false;
      });
      debugPrint("Error loading interactions: $e");
    }
  }

  void _filterRecommendations() {
    setState(() {
      filteredRecommendations = widget.recommendations.where((user) {
        final email = (user['email'] ?? "").toString().toLowerCase();
        return email.isNotEmpty &&
            !likedEmails.contains(email) &&
            !matchedEmails.contains(email) &&
            email != widget.userEmail.toLowerCase();
      }).toList();
    });
  }

  // ===========================
  // UI DIALOGS
  // ===========================

  void _showLikeReceivedDialog(String from, Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated heart
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink.shade400, Colors.red.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite, size: 45, color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Text(
                  "💖 Someone likes you!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${data['fromData']?['nickname'] ?? from} thinks you\'re amazing! Like them back to create a match.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectLike(from);
                          setState(() {
                            pendingLikes.removeWhere((element) => element['from'] == from);
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          'Not Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _acceptLike(from);
                          setState(() {
                            pendingLikes.removeWhere((element) => element['from'] == from);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Like Back ❤️',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMatchDialog(String matchedUser, Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Match animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 50,
                          color: Colors.pink,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Text(
                  "🎉 It's a Match!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You and $matchedUser liked each other!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: const Text(
                          'Keep Swiping',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedChatScreen(
                                currentUserEmail: widget.userEmail,
                                otherUserEmail: matchedUser,
                                chatId: data['chatId'] ?? 'chat_${widget.userEmail}_$matchedUser',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Start Chat 💬',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ===========================
  // PROFILE CARD BUILDER
  // ===========================

  Widget _buildProfileCard(Map<String, dynamic> profile, int index) {
    final name = profile['nickname'] ?? profile['name'] ?? 'Someone Special';
    final age = profile['age']?.toString() ?? '';
    final about = profile['about'] ?? profile['bio'] ?? profile['description'] ?? '';
    final imageUrl = profile['profileImage'] ?? profile['imageUrl'] ?? '';
    final location = profile['location'] ?? profile['city'] ?? '';
    final matchScore = profile['match_score'] ?? profile['compatibility'] ?? '95';
    final interests = (profile['interests'] as List?)?.take(3).toList() ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=600&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),

            // Match Score Badge
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.purple.shade500],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$matchScore%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Connection Status Badge
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isBackendConnected ? Colors.green.shade500 : Colors.orange.shade500,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isBackendConnected ? Colors.green : Colors.orange).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isBackendConnected ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isBackendConnected ? "Online" : "Offline",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Age
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (age.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              age,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Location
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Bio
                    if (about.isNotEmpty)
                      Text(
                        about,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 20),

                    // Interests
                    if (interests.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: interests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              interest.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String label,
    required VoidCallback onPressed,
    double size = 68,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: size * 0.45),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ===========================
  // MAIN BUILD METHOD
  // ===========================

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInteractions) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pink.shade400),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                "Finding amazing people for you...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Connection status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isBackendConnected ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isBackendConnected ? Colors.green.shade300 : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isBackendConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isBackendConnected ? Colors.green.shade600 : Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBackendConnected ? 'Connected to server' : 'Connecting to server...',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isBackendConnected ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredRecommendations.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                "No more profiles to show",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Check back later for new matches!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _loadUserInteractions().then((_) => _filterRecommendations());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _fadeAnimation == null
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeAnimation!,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade400, Colors.purple.shade500],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Luvvy',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Connection status indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isBackendConnected ? Colors.green : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.favorite, color: Colors.pink),
                                if (pendingLikes.isNotEmpty)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          pendingLikes.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InterestsPage(userEmail: widget.userEmail),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble, color: Colors.purple),
                            onPressed: () {
                              // Navigate to matches/chats page
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "${filteredRecommendations.length} profiles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.pink.shade400, Colors.purple.shade500],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isBackendConnected ? '🟢' : '🟠',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Cards
              Expanded(
                child: SwipableStack(
                  controller: _swipeController,
                  itemCount: filteredRecommendations.length,
                  builder: (context, properties) {
                    final profile = filteredRecommendations[properties.index];
                    return _buildProfileCard(profile, properties.index);
                  },
                  onSwipeCompleted: (index, direction) {
                    final user = filteredRecommendations[index];
                    final email = (user['email'] ?? '').toString().toLowerCase();

                    if (direction == SwipeDirection.right && email.isNotEmpty) {
                      print('👍 Swiped right on: $email');
                      _likeUser(email);
                      _filterRecommendations();
                    } else if (direction == SwipeDirection.left) {
                      print('👎 Swiped left on: $email');
                      // Could add "pass" functionality here
                    }
                  },
                ),
              ),

              // Action Buttons
              _buttonAnimation == null
                  ? Container()
                  : AnimatedBuilder(
                animation: _buttonAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation!.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.close,
                            color: Colors.red.shade500,
                            backgroundColor: Colors.white,
                            label: "Nope",
                            onPressed: () {
                              if (filteredRecommendations.isNotEmpty) {
                                _swipeController.next(swipeDirection: SwipeDirection.left);
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.star,
                            color: Colors.blue.shade500,
                            backgroundColor: Colors.white,
                            label: "Super",
                            size: 78,
                            onPressed: () {
                              if (filteredRecommendations.isNotEmpty) {
                                _swipeController.next(swipeDirection: SwipeDirection.up);
                              }
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.favorite,
                            color: Colors.pink.shade500,
                            backgroundColor: Colors.white,
                            label: "Like",
                            onPressed: () {
                              if (filteredRecommendations.isNotEmpty) {
                                _swipeController.next(swipeDirection: SwipeDirection.right);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _buttonController?.dispose();
    super.dispose();
  }
}
