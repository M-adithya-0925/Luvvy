import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luvvy/DistanceRange.dart';
import 'services/FirebaseService.dart';

class RelationshipGoalsScreen extends StatefulWidget {
  const RelationshipGoalsScreen({super.key});

  @override
  State<RelationshipGoalsScreen> createState() => _RelationshipGoalsScreenState();
}

class _RelationshipGoalsScreenState extends State<RelationshipGoalsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedGoal;
  bool _isLoading = false;
  bool _showAllOptions = false;

  AnimationController? _progressController;
  Animation<double>? _progressAnimation;

  // ✅ Comprehensive relationship goals with subcategories
  final List<RelationshipGoal> primaryGoals = [
    RelationshipGoal(
      title: "Dating & Romance",
      emoji: "💕",
      description: "Looking for romantic connections and dating",
      color: Colors.pink,
      isCategory: true,
    ),
    RelationshipGoal(
      title: "Casual & Fun",
      emoji: "😎",
      description: "Casual encounters, hookups, and fun connections",
      color: Colors.orange,
      isCategory: true,
    ),
    RelationshipGoal(
      title: "Serious Commitment",
      emoji: "💍",
      description: "Long-term relationships and marriage",
      color: Colors.purple,
      isCategory: true,
    ),
    RelationshipGoal(
      title: "Friendship",
      emoji: "🤝",
      description: "Making new friends and social connections",
      color: Colors.blue,
      isCategory: true,
    ),
  ];

  final List<RelationshipGoal> allGoals = [
    // Dating & Romance
    RelationshipGoal(
      title: "Traditional Dating",
      emoji: "💑",
      description: "Classic dating for heterosexual relationships",
      color: Colors.pink,
    ),
    RelationshipGoal(
      title: "Gay Dating",
      emoji: "🏳️‍🌈",
      description: "Dating for gay men seeking meaningful connections",
      color: Colors.deepPurple, // ✅ FIXED: Changed from Colors.rainbow
    ),
    RelationshipGoal(
      title: "Lesbian Dating",
      emoji: "👭",
      description: "Dating for lesbian women seeking love",
      color: Colors.pink.shade300,
    ),
    RelationshipGoal(
      title: "Bisexual Dating",
      emoji: "💖",
      description: "Dating for bisexual individuals",
      color: Colors.purple.shade300,
    ),
    RelationshipGoal(
      title: "Pansexual Dating",
      emoji: "🌈",
      description: "Dating regardless of gender identity",
      color: Colors.yellow.shade600,
    ),

    // Casual & Fun
    RelationshipGoal(
      title: "Hookups",
      emoji: "🔥",
      description: "Casual physical encounters, no strings attached",
      color: Colors.red,
    ),
    RelationshipGoal(
      title: "Friends with Benefits",
      emoji: "😉",
      description: "Friendship with physical intimacy",
      color: Colors.orange,
    ),
    RelationshipGoal(
      title: "Situationship",
      emoji: "🤷‍♂️",
      description: "Undefined romantic connection, somewhere between dating and friendship",
      color: Colors.amber,
    ),
    RelationshipGoal(
      title: "Casual Dating",
      emoji: "☕",
      description: "Low-commitment dating, keeping things light",
      color: Colors.orange.shade300,
    ),
    RelationshipGoal(
      title: "Short-term Fun",
      emoji: "🎉",
      description: "Temporary connections while traveling or short stays",
      color: Colors.deepOrange,
    ),

    // Serious Commitment
    RelationshipGoal(
      title: "Long-term Relationship",
      emoji: "💞",
      description: "Committed relationship with future plans",
      color: Colors.purple,
    ),
    RelationshipGoal(
      title: "Marriage-minded",
      emoji: "💒",
      description: "Actively seeking marriage and life partnership",
      color: Colors.deepPurple,
    ),
    RelationshipGoal(
      title: "Life Partnership",
      emoji: "👫",
      description: "Deep commitment, may or may not include marriage",
      color: Colors.indigo,
    ),
    RelationshipGoal(
      title: "Polyamory",
      emoji: "💝",
      description: "Multiple loving relationships with consent",
      color: Colors.pink.shade700,
    ),
    RelationshipGoal(
      title: "Open Relationship",
      emoji: "🔓",
      description: "Committed relationship allowing other connections",
      color: Colors.teal,
    ),

    // Friendship & Social
    RelationshipGoal(
      title: "Platonic Friends",
      emoji: "🤗",
      description: "Just friends, no romantic interest",
      color: Colors.blue,
    ),
    RelationshipGoal(
      title: "Activity Partners",
      emoji: "🏃‍♂️",
      description: "Friends for hobbies, sports, or activities",
      color: Colors.green,
    ),
    RelationshipGoal(
      title: "Travel Companions",
      emoji: "✈️",
      description: "Friends to explore and travel with",
      color: Colors.lightBlue,
    ),
    RelationshipGoal(
      title: "Professional Networking",
      emoji: "💼",
      description: "Career connections and professional relationships",
      color: Colors.blueGrey,
    ),
    RelationshipGoal(
      title: "Study Buddies",
      emoji: "📚",
      description: "Academic support and study partners",
      color: Colors.cyan,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(_progressController!);
  }

  void _selectGoal(String goal) {
    setState(() {
      selectedGoal = goal;
    });
  }

  void _toggleShowAllOptions() {
    setState(() {
      _showAllOptions = !_showAllOptions;
    });
  }

  Future<void> _handleContinue() async {
    if (selectedGoal == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _progressController?.forward();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'relationshipGoal': selectedGoal!,
        'relationshipGoalUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Also save via FirebaseService if available
      // await FirebaseService().updateRelationshipGoal(selectedGoal!);

      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DistancePreferenceScreen())
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _progressController?.reset();
      }
    }
  }

  Widget _buildGoalCard(RelationshipGoal goal, {bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? goal.color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? goal.color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: goal.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: goal.isCategory ? null : () => _selectGoal(goal.title),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected || goal.isCategory
                        ? goal.color.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: TextStyle(
                                fontSize: goal.isCategory ? 18 : 16,
                                fontWeight: goal.isCategory ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? goal.color :
                                goal.isCategory ? goal.color : Colors.black87,
                              ),
                            ),
                          ),
                          if (goal.isCategory)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: goal.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "CATEGORY",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: goal.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: goal.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _toggleShowAllOptions,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showAllOptions ? Icons.visibility_off : Icons.visibility,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _showAllOptions ? "Show Categories Only" : "Show All Relationship Types",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Back button and progress
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressAnimation?.value ?? 0.75,
                      minHeight: 6,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF8000FF)),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),

            // Title section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "What are you looking for? ",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text("💘", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Be specific about your relationship goals. This helps us find the right matches for you.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Relationship options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Show categories or all options based on toggle
                  if (!_showAllOptions) ...[
                    // Categories only
                    ...primaryGoals.map(
                          (goal) => _buildGoalCard(goal, isSelected: false),
                    ),
                  ] else ...[
                    // All specific options
                    ...allGoals.map(
                          (goal) => _buildGoalCard(
                        goal,
                        isSelected: selectedGoal == goal.title,
                      ),
                    ),
                  ],

                  // Toggle button
                  _buildShowMoreButton(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Continue button
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: selectedGoal != null && !_isLoading
                ? _handleContinue
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8000FF),
              disabledBackgroundColor: Colors.grey.shade400,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              selectedGoal != null
                  ? "Continue with $selectedGoal"
                  : "Select your goal",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController?.dispose();
    super.dispose();
  }
}

// ✅ Data model for relationship goals
class RelationshipGoal {
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final bool isCategory;

  RelationshipGoal({
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    this.isCategory = false,
  });
}
