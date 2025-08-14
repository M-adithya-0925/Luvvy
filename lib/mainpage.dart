import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luvvy/InterestsPage.dart';
import 'package:luvvy/ProfilePage.dart';
import 'package:luvvy/SettingsPage.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:luvvy/chat.dart';
class MainPage extends StatefulWidget {
  final String userEmail;
  final List<dynamic> recommendations;

  const MainPage({
    super.key,
    required this.userEmail,
    required this.recommendations,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  /// Helper to get value from multiple possible keys
  String getValue(Map<String, dynamic> data, List<String> keys) {
    for (var key in keys) {
      if (data.containsKey(key) &&
          data[key] != null &&
          data[key].toString().isNotEmpty) {
        return data[key].toString();
      }
    }
    return "";
  }

  /// Save liked user to the existing Firestore document
  Future<void> _saveLikedUser(Map<String, dynamic> likedUser) async {
    try {
      // Find the user's document by email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({
          'liked': FieldValue.arrayUnion([likedUser]),
        });

        debugPrint("Liked user saved successfully to existing document!");
      } else {
        debugPrint("No document found for email ${widget.userEmail}");
      }
    } catch (e) {
      debugPrint("Error saving liked user: $e");
    }
  }

  Widget buildSwipeCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 380
        ? screenWidth * 0.95
        : screenWidth < 500
        ? screenWidth * 0.9
        : 420.0;

    if (widget.recommendations.isEmpty) {
      return const Center(
        child: Text(
          "No matches found 😔",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: SwipableStack(
          itemCount: widget.recommendations.length,
          builder: (context, properties) {
            final match = Map<String, dynamic>.from(
                widget.recommendations[properties.index]);

            final name =
            getValue(match, ['nickname', 'full_name', 'username']);
            final imageUrl =
            getValue(match, ['profileImage', 'image_url', 'avatar']);
            final bio =
            getValue(match, ['story', 'about', 'description']);
            final score =
            getValue(match, ['match_score', 'score', 'percentage']);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F1FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(
                        imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name.isNotEmpty ? name : "Unknown",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        bio.isNotEmpty ? bio : "No bio available",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        score.isNotEmpty
                            ? "💜 Match Score: $score%"
                            : "💜 Match Score: 0%",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          onSwipeCompleted: (index, direction) async {
            debugPrint(
                "Swiped $direction on ${widget.recommendations[index]}");

            if (direction == SwipeDirection.right) {
              await _saveLikedUser(
                Map<String, dynamic>.from(widget.recommendations[index]),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildSwipeCards(),
      InterestsPage(userId: widget.userEmail),
      ProfilePage(userId: widget.userEmail),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.userEmail}',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.purple,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(userEmail: widget.userEmail),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.purple.shade700),
            ),
          )
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Interests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
