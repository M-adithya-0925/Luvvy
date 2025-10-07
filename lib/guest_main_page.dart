import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'sign_up_screen.dart';
import 'dart:math' as math;

class GuestMainPage extends StatefulWidget {
  const GuestMainPage({super.key});

  @override
  State<GuestMainPage> createState() => _GuestMainPageState();
}

class _GuestMainPageState extends State<GuestMainPage> with TickerProviderStateMixin {
  SwipableStackController _swipeController = SwipableStackController();
  
  int swipeCount = 0;
  final int maxSwipes = 5;
  List<Map<String, dynamic>> demoUsers = [];
  bool isLocked = false;
  
  AnimationController? _fadeController;
  AnimationController? _buttonController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSwipeCount();
    _generateDemoUsers();
    
    _fadeController?.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _buttonController?.forward();
    });
  }

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

  Future<void> _loadSwipeCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      swipeCount = prefs.getInt('guest_swipe_count') ?? 0;
      isLocked = swipeCount >= maxSwipes;
    });
  }

  Future<void> _saveSwipeCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('guest_swipe_count', swipeCount);
  }

  void _generateDemoUsers() {
    final random = math.Random();
    final names = ['Alex', 'Jordan', 'Casey', 'Riley', 'Avery', 'Blake', 'Cameron', 'Drew', 'Ellis', 'Finley'];
    final bios = [
      'Love hiking and outdoor adventures 🏔️',
      'Coffee enthusiast and book lover ☕📚',
      'Yoga instructor and wellness coach 🧘‍♀️',
      'Travel blogger exploring the world 🌍',
      'Music lover and concert goer 🎵',
      'Foodie trying new cuisines 🍜',
      'Fitness trainer and marathon runner 🏃‍♂️',
      'Art lover and weekend painter 🎨',
      'Tech enthusiast and gamer 🎮',
      'Dog lover and volunteer 🐕',
    ];
    final locations = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego'];

    demoUsers = List.generate(10, (index) {
      return {
        'name': names[index % names.length],
        'nickname': names[index % names.length],
        'age': (20 + random.nextInt(15)).toString(),
        'about': bios[index % bios.length],
        'bio': bios[index % bios.length],
        'location': locations[index % locations.length],
        'city': locations[index % locations.length],
        'match_score': (85 + random.nextInt(15)).toString(),
        'compatibility': (85 + random.nextInt(15)).toString(),
        'profileImage': 'https://images.unsplash.com/photo-${1494790000000 + (index * 1000)}?w=400&h=600&fit=crop',
        'imageUrl': 'https://images.unsplash.com/photo-${1494790000000 + (index * 1000)}?w=400&h=600&fit=crop',
        'interests': ['Travel', 'Music', 'Food', 'Sports', 'Art'].take(3).toList(),
        'email': 'demo${index + 1}@example.com',
      };
    });
  }

  void _handleSwipe() {
    if (isLocked) return;

    setState(() {
      swipeCount++;
    });
    
    _saveSwipeCount();

    if (swipeCount >= maxSwipes) {
      setState(() {
        isLocked = true;
      });
      _showLimitReachedDialog();
    }
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.pink.shade500],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "🚀 Ready to find love?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "You've reached your guest limit of $maxSwipes swipes! Create an account to continue discovering amazing people and unlock unlimited matches.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    // Sign Up Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Account - It\'s Free! 💜',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Back to Login Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
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

  Widget _buildProfileCard(Map<String, dynamic> profile, int index) {
    final name = profile['name'] ?? 'Someone Special';
    final age = profile['age']?.toString() ?? '';
    final about = profile['about'] ?? '';
    final imageUrl = profile['profileImage'] ?? '';
    final location = profile['location'] ?? '';
    final matchScore = profile['match_score'] ?? '95';
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

            // Demo Badge
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade500,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "DEMO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
          onTap: isLocked ? null : onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade300 : backgroundColor,
              shape: BoxShape.circle,
              boxShadow: isLocked ? [] : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon, 
              color: isLocked ? Colors.grey.shade500 : color, 
              size: size * 0.45
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isLocked ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (demoUsers.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
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
                        'Datify Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.red.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLocked ? Colors.red.shade300 : Colors.orange.shade300,
                        ),
                      ),
                      child: Text(
                        '$swipeCount/$maxSwipes swipes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.red.shade700 : Colors.orange.shade700,
                        ),
                      ),
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
                      isLocked ? "Guest limit reached" : "${demoUsers.length} demo profiles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? Colors.red.shade600 : Colors.grey.shade600,
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
                          widthFactor: swipeCount / maxSwipes,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLocked 
                                    ? [Colors.red.shade400, Colors.red.shade600]
                                    : [Colors.pink.shade400, Colors.purple.shade500],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards
              Expanded(
                child: isLocked
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Guest limit reached!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Create an account for unlimited swipes",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                "Sign Up Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SwipableStack(
                        controller: _swipeController,
                        itemCount: demoUsers.length,
                        builder: (context, properties) {
                          final profile = demoUsers[properties.index];
                          return _buildProfileCard(profile, properties.index);
                        },
                        onSwipeCompleted: (index, direction) {
                          if (!isLocked) {
                            _handleSwipe();
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
                              if (!isLocked) {
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
                              if (!isLocked) {
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
                              if (!isLocked) {
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
