import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static Future<String> createOrGetChatId(String user1, String user2) async {
    // Create consistent chat ID regardless of user order
    final List<String> participants = [user1, user2]..sort();
    final String chatId = '${participants[0]}_${participants[1]}';

    try {
      final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
      final chatSnapshot = await chatDoc.get();

      if (!chatSnapshot.exists) {
        // Create new chat document
        await chatDoc.set({
          'participants': participants,
          'createdAt': Timestamp.now(),
          'lastMessage': '',
          'lastMessageTime': null,
          'unreadCount': {
            user1: 0,
            user2: 0,
          },
        });
        print('✅ Created new chat: $chatId');
      } else {
        print('✅ Chat already exists: $chatId');
      }

      return chatId;
    } catch (error) {
      print('❌ Error creating/getting chat: $error');
      rethrow;
    }
  }

  static Future<void> updateChatOnMatch(String user1, String user2) async {
    try {
      print('🎉 Creating chat for match: $user1 ↔ $user2');

      final chatId = await createOrGetChatId(user1, user2);

      // Send initial system message
      final messageRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'id': messageRef.id,
        'text': '🎉 You matched! Start your conversation here.',
        'senderId': 'system',
        'receiverId': 'system',
        'timestamp': Timestamp.now(),
        'type': 'system',
        'isRead': false,
      });

      // Update chat metadata
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .update({
        'lastMessage': '🎉 You matched! Start your conversation here.',
        'lastMessageTime': Timestamp.now(),
      });

      print('✅ Match chat created successfully');
    } catch (error) {
      print('❌ Error updating chat on match: $error');
    }
  }
}
