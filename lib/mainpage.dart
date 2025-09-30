import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'services/socket_service.dart';

import 'chat.dart';
import 'InterestsPage.dart';
import 'terms_conditions.dart';

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

class _MainPageState extends State<MainPage> {
  final SocketService _socket = SocketService.instance;
  SwipableStackController _swipeController = SwipableStackController();

  Set<String> likedUserEmails = {};
  Set<String> matchedUserEmails = {};
  List<Map<String, dynamic>> pendingLikes = [];

  @override
  void initState() {
    super.initState();
    _socket.connect(widget.userEmail);

    _socket.onLikeReceived = (data) {
      setState(() => pendingLikes.add({'from': data['from']}));
      _showLikeNotification(data['from']);
    };

    _socket.onMatchCreated = (data) {
      setState(() {
        matchedUserEmails.add(data['with']);
        likedUserEmails.add(data['with']);
      });
      _showTermsAndConditions(data['with']);
    };

    _socket.onError = (msg) => _showError(msg);
  }

  List<dynamic> get filteredRecommendations =>
      widget.recommendations.where((user) =>
      !likedUserEmails.contains(user['email']) &&
          !matchedUserEmails.contains(user['email'])).toList();

  void _showLikeNotification(String from) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("💖 New Like!"),
        content: Text('$from liked you!'),
        actions: [
          TextButton(
            child: const Text('Pass'),
            onPressed: () {
              _socket.rejectLike(from);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text('Like Back'),
            onPressed: () {
              _socket.acceptLike(from);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(String withUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsConditionsScreen(
          onAccept: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ChatPage(
                    userEmail: widget.userEmail,
                    otherUserEmail: withUser
                )
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luvvy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(
                  builder: (_) => InterestsPage(userEmail: widget.userEmail))
              );
            },
          ),
        ],
      ),
      body: filteredRecommendations.isEmpty
          ? Center(child: Text("No more recommendations"))
          : SwipableStack(
        controller: _swipeController,
        itemCount: filteredRecommendations.length,
        builder: (context, properties) {
          final profile = filteredRecommendations[properties.index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: NetworkImage(profile['profileImage'] ?? 'https://via.placeholder.com/150'),
                ),
                Text(profile['nickname'] ?? 'Someone', style: TextStyle(fontSize: 20)),
                Text(profile['about'] ?? '', textAlign: TextAlign.center),
              ],
            ),
          );
        },
        onSwipeCompleted: (index, direction) {
          final user = filteredRecommendations[index];
          final email = user['email'];
          if (direction == SwipeDirection.right && email != null) {
            likedUserEmails.add(email);
            _socket.likeUser(email);
            setState(() {});
          }
        },
      ),
      floatingActionButton: pendingLikes.isNotEmpty
          ? FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showLikeNotification(pendingLikes.last['from']),
        child: Icon(Icons.favorite),
      )
          : null,
    );
  }
}
