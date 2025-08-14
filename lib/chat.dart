import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final String userEmail;

  const ChatPage({super.key, required this.userEmail});

  Stream<QuerySnapshot> getUserChats() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: userEmail)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet 💬"));
          }

          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants =
              List<String>.from(chat['participants']);
              final otherUser = participants.firstWhere(
                      (p) => p != userEmail,
                  orElse: () => "Unknown");

              return ListTile(
                title: Text(otherUser),
                subtitle: Text(chat['lastMessage'] ?? ""),
                onTap: () {
                  // TODO: Navigate to a detailed chat screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
