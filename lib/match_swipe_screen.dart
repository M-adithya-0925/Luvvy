import 'package:flutter/material.dart';

class MatchSwipeScreen extends StatefulWidget {
  @override
  _MatchSwipeScreenState createState() => _MatchSwipeScreenState();
}

class _MatchSwipeScreenState extends State<MatchSwipeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> profiles = [
    {"name": "Monica", "age": 24, "image": "assets/girl1.jpg", "distance": "5 km"},
    {"name": "Isabella", "age": 22, "image": "assets/girl2.jpg", "distance": "4 km"},
    {"name": "Elizabeth", "age": 25, "image": "assets/girl3.jpg", "distance": "7 km"},
    {"name": "Amelia", "age": 24, "image": "assets/girl4.jpg", "distance": "3 km"},
  ];

  void _onLike() {
    _showMatchIfNeeded();
    setState(() {
      currentIndex++;
    });
  }

  void _onSuperLike() {
    _showMatchIfNeeded(isSuperLike: true);
    setState(() {
      currentIndex++;
    });
  }

  void _onNope() {
    setState(() {
      currentIndex++;
    });
  }

  void _showMatchIfNeeded({bool isSuperLike = false}) {
    if (currentIndex == 3) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 60, color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'You Got the Match!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                'You both liked each other. Start a conversation now!',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Let\'s Chat'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Maybe Later'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= profiles.length) {
      return Scaffold(
        body: Center(
          child: Text("No more profiles", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final profile = profiles[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Datify", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.chat_bubble_outline, color: Colors.black)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(profile["image"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profile['name']} (${profile['age']})",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile['distance'] + " away",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(Icons.close, Colors.redAccent, _onNope),
              _actionButton(Icons.star, Colors.blue, _onSuperLike),
              _actionButton(Icons.favorite, Colors.purple, _onLike),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        radius: 32,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
