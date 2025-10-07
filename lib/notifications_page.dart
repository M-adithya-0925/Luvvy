// notifications_page.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userEmail;

  const NotificationsPage({super.key, required this.userEmail});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    setState(() => isLoading = true);
    final notifs = await ApiService.getNotifications(widget.userEmail);
    setState(() {
      notifications = notifs;
      isLoading = false;
    });
  }

  void _handleAcceptLike(Map<String, dynamic> notification) async {
    final result = await ApiService.acceptLike(
      widget.userEmail,
      notification['from']['email'],
      notification['id'],
    );

    if (result != null && result['success'] == true) {
      if (result['mutual_match'] == true) {
        // Show match dialog
        _showMatchDialog(notification['from']);
      }
      _loadNotifications(); // Refresh
    }
  }

  void _handleRejectLike(Map<String, dynamic> notification) async {
    final success = await ApiService.rejectLike(
      widget.userEmail,
      notification['from']['email'],
      notification['id'],
    );

    if (success) {
      _loadNotifications(); // Refresh
    }
  }

  void _showMatchDialog(Map<String, dynamic> matchedUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 It\'s a Match!'),
        content: Text('You and ${matchedUser['nickname']} liked each other!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to chat
            },
            child: Text('Start Chatting'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(child: Text('No notifications yet'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(notif['from']['nickname'][0]),
                        ),
                        title: Text('${notif['from']['nickname']} liked you! 💖'),
                        subtitle: Text(notif['message']),
                        trailing: notif['status'] == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _handleRejectLike(notif),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.favorite, color: Colors.pink),
                                    onPressed: () => _handleAcceptLike(notif),
                                  ),
                                ],
                              )
                            : Icon(
                                notif['status'] == 'accepted' ? Icons.check : Icons.close,
                                color: notif['status'] == 'accepted' ? Colors.green : Colors.red,
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
