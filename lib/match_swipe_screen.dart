import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/FirebaseService.dart';
import 'Login_Screen.dart';

class MatchSwipeScreen extends StatefulWidget {
  @override
  _MatchSwipeScreenState createState() => _MatchSwipeScreenState();
}

class _MatchSwipeScreenState extends State<MatchSwipeScreen> with TickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _cardController;
  late AnimationController _buttonController;

  final List<Map<String, dynamic>> profiles = [
    {"name": "Monica", "age": 24, "image": "assets/girl1.jpg", "distance": "5 km", "bio": "Love hiking and coffee ☕"},
    {"name": "Isabella", "age": 22, "image": "assets/girl2.jpg", "distance": "4 km", "bio": "Artist and yoga enthusiast 🧘‍♀️"},
    {"name": "Elizabeth", "age": 25, "image": "assets/girl3.jpg", "distance": "7 km", "bio": "Foodie exploring the city 🍕"},
    {"name": "Amelia", "age": 24, "image": "assets/girl4.jpg", "distance": "3 km", "bio": "Dancing through life 💃"},
  ];

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _buttonController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _cardController.forward();
    _buttonController.forward();
  }

  void _onLike() {
    _animateAction(Colors.green);
    _showMatchIfNeeded();
    _nextProfile();
  }

  void _onSuperLike() {
    _animateAction(Colors.blue);
    _showMatchIfNeeded(isSuperLike: true);
    _nextProfile();
  }

  void _onNope() {
    _animateAction(Colors.red);
    _nextProfile();
  }

  void _animateAction(Color color) {
    _cardController.reverse().then((_) {
      _cardController.forward();
    });
  }

  void _nextProfile() {
    setState(() {
      currentIndex++;
    });

    if (currentIndex >= profiles.length) {
      // Show registration success after viewing all profiles
      Future.delayed(const Duration(milliseconds: 500), () {
        _showRegistrationSuccess();
      });
    }
  }

  void _showMatchIfNeeded({bool isSuperLike = false}) {
    if (currentIndex == 2) { // Show match on 3rd profile
      Future.delayed(const Duration(milliseconds: 300), () {
        _showMatchDialog(isSuperLike);
      });
    }
  }

  void _showMatchDialog(bool isSuperLike) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                  duration: const Duration(seconds: 1),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSuperLike
                                ? [Colors.blue.shade400, Colors.blue.shade600]
                                : [Colors.pink.shade400, Colors.red.shade500],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuperLike ? Icons.star : Icons.favorite,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  isSuperLike ? "Super Match!" : "It's a Match!",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isSuperLike
                      ? "You super liked each other! This is rare!"
                      : "You both liked each other. Start a conversation now!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Let's Chat",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8B5CF6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Maybe Later",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5CF6),
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

  void _showRegistrationSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= profiles.length) {
      return Scaffold(
        backgroundColor: const Color(0xFF8B5CF6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "Completing your registration...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profiles[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Luvvy",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "3",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / profiles.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
            ),
          ),

          // Profile card
          Expanded(
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardController.value,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Background image
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(profile["image"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),

                          // Profile info
                          Positioned(
                            bottom: 30,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile['name'],
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${profile['age']}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile['distance'] + " away",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile['bio'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Online indicator
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Colors.white, size: 8),
                                  SizedBox(width: 4),
                                  Text(
                                    "Online",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Action buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AnimatedBuilder(
              animation: _buttonController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonController.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        Icons.close,
                        Colors.red.shade400,
                        Colors.red.shade50,
                        _onNope,
                        "Nope",
                      ),
                      _actionButton(
                        Icons.star,
                        Colors.blue.shade400,
                        Colors.blue.shade50,
                        _onSuperLike,
                        "Super",
                      ),
                      _actionButton(
                        Icons.favorite,
                        const Color(0xFF8B5CF6),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                        _onLike,
                        "Like",
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, Color backgroundColor, VoidCallback onPressed, String label) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _buttonController.dispose();
    super.dispose();
  }
}

// Registration Success Screen
class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _detailsController;
  late Animation<double> _successAnimation;
  late Animation<double> _detailsAnimation;

  Map<String, dynamic> userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _detailsController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut)
    );
    _detailsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _detailsController, curve: Curves.easeInOut)
    );

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data() ?? {};
            _isLoading = false;
          });

          _successController.forward();
          await Future.delayed(const Duration(milliseconds: 500));
          _detailsController.forward();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        userData = {
          'name': 'User',
          'email': 'user@example.com',
          'age': 25,
          'gender': 'Not specified',
          'relationshipGoal': 'Dating',
          'interests': ['Photography', 'Travel', 'Music'],
          'distanceRange': 50,
        };
      });
      _successController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      _detailsController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5CF6),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success animation
              AnimatedBuilder(
                animation: _successAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _successAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              const Text(
                "Registration Successful!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "Welcome to Luvvy! Your profile has been created successfully.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // User details
              AnimatedBuilder(
                animation: _detailsAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _detailsAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - _detailsAnimation.value)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Profile Summary",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 24),

                            _buildDetailRow("Name", userData['name'] ?? 'Not provided', Icons.person),
                            _buildDetailRow("Email", userData['email'] ?? 'Not provided', Icons.email),
                            _buildDetailRow("Age", "${userData['age'] ?? 'Not provided'}", Icons.cake),
                            _buildDetailRow("Gender", userData['gender'] ?? 'Not provided', Icons.wc),
                            _buildDetailRow("Looking for", userData['relationshipGoal'] ?? 'Not specified', Icons.favorite),
                            _buildDetailRow("Distance Range", "${userData['distanceRange'] ?? 50} km", Icons.location_on),

                            if (userData['interests'] != null && (userData['interests'] as List).isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                "Interests",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (userData['interests'] as List<dynamic>)
                                    .map((interest) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    interest.toString(),
                                    style: TextStyle(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue to Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}
