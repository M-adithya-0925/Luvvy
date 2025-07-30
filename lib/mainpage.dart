import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final int userId; // Pass the logged-in user's ID
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> recommendedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendedUsers();
  }

  Future<void> fetchRecommendedUsers() async {
    final uri = Uri.parse('http://192.168.29.86:5000/recommend?user_id=${widget.userId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recommendedUsers = data['recommended_matches'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch recommendations");
      }
    } catch (e) {
      print("❌ Error fetching recommendations: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.female, color: Colors.purple),
                  Spacer(),
                  Text(
                    "Datify",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(Icons.notifications_none, color: Colors.black),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                itemCount: recommendedUsers.length,
                itemBuilder: (context, index) {
                  final user = recommendedUsers[index];
                  return UserCard(
                    name: user['name'],
                    age: user['age'],
                    distance: "Nearby", // optionally add location logic
                    imageUrl: getRandomImage(user['name']),
                    bio: user['bio'] ?? '',
                    interests: List<String>.from(user['interests'] ?? []),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRandomImage(String seed) {
    // Use unique images per name (placeholder logic)
    return "https://source.unsplash.com/random/400x600/?face,$seed";
  }
}
class UserCard extends StatelessWidget {
  final String name;
  final int age;
  final String distance;
  final String imageUrl;
  final String bio;
  final List<String> interests;

  const UserCard({
    super.key,
    required this.name,
    required this.age,
    required this.distance,
    required this.imageUrl,
    required this.bio,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 30,
          right: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$name ($age)", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(distance, style: const TextStyle(color: Colors.white, fontSize: 16)),
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (interests.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: interests.take(4).map((e) => Chip(
                    label: Text(e, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.purple.withOpacity(0.7),
                  )).toList(),
                )
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(Icons.clear, Colors.red),
                  _actionButton(Icons.star, Colors.orange),
                  _actionButton(Icons.favorite, Colors.purple),
                  _actionButton(Icons.flash_on, Colors.blue),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 26,
      child: Icon(icon, color: color, size: 30),
    );
  }
}
