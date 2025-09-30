import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RelationshipGoals.dart';
import 'services/FirebaseService.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedGender;
  bool _isLoading = false;
  bool _showMoreOptions = false;

  // ✅ FIXED: Make nullable initially
  AnimationController? _controller;
  Animation<double>? _progressAnimation;

  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Initialize properly
    _initializeController();
  }

  void _initializeController() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.5,
      end: 0.75,
    ).animate(_controller!);
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void _toggleMoreOptions() {
    setState(() {
      _showMoreOptions = !_showMoreOptions;
    });
  }

  Future<void> _handleContinue() async {
    if (selectedGender == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ FIXED: Add null safety check
      _controller?.forward();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'gender': selectedGender!,
        'genderUpdatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseService().updateGender(selectedGender!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RelationshipGoalsScreen()),
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
        _controller?.reset();
      }
    }
  }

  Widget _buildGenderCard(String name, String description, String icon, Color color, {bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectGender(name),
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
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Check icon
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
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

  Widget _buildMoreOptionsButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _toggleMoreOptions,
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
                Text(
                  _showMoreOptions ? "Show Less" : "More Options",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _showMoreOptions ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more),
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
            // Header with back button and progress
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
                      value: _progressAnimation?.value ?? 0.5,
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
                      const Text(
                        "Choose your gender ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "🏳️‍⚧️",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This helps us create better matches for you",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Gender options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Primary options
                  _buildGenderCard(
                    "Man",
                    "Male",
                    "👨",
                    Colors.blue,
                    isSelected: selectedGender == "Man",
                  ),
                  _buildGenderCard(
                    "Woman",
                    "Female",
                    "👩",
                    Colors.pink,
                    isSelected: selectedGender == "Woman",
                  ),
                  _buildGenderCard(
                    "Non-binary",
                    "Neither exclusively male nor female",
                    "🧑",
                    Colors.purple,
                    isSelected: selectedGender == "Non-binary",
                  ),

                  // More options button
                  _buildMoreOptionsButton(),

                  // Additional options
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        _buildGenderCard(
                          "Transgender Woman",
                          "Trans woman",
                          "🏳️‍⚧️",
                          Colors.pink.shade400,
                          isSelected: selectedGender == "Transgender Woman",
                        ),
                        _buildGenderCard(
                          "Transgender Man",
                          "Trans man",
                          "🏳️‍⚧️",
                          Colors.blue.shade400,
                          isSelected: selectedGender == "Transgender Man",
                        ),
                        _buildGenderCard(
                          "Hijra/Third Gender",
                          "Recognized third gender in India",
                          "🕉️",
                          Colors.orange,
                          isSelected: selectedGender == "Hijra/Third Gender",
                        ),
                        _buildGenderCard(
                          "Genderfluid",
                          "Gender identity varies",
                          "🌊",
                          Colors.teal,
                          isSelected: selectedGender == "Genderfluid",
                        ),
                        _buildGenderCard(
                          "Agender",
                          "No gender identity",
                          "⚪",
                          Colors.grey,
                          isSelected: selectedGender == "Agender",
                        ),
                        _buildGenderCard(
                          "Other",
                          "Other identity",
                          "✨",
                          Colors.amber,
                          isSelected: selectedGender == "Other",
                        ),
                        _buildGenderCard(
                          "Prefer not to say",
                          "Keep private",
                          "🤐",
                          Colors.blueGrey,
                          isSelected: selectedGender == "Prefer not to say",
                        ),
                      ],
                    ),
                    crossFadeState: _showMoreOptions
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

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
            onPressed: selectedGender != null && !_isLoading
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
                : const Text(
              "Continue",
              style: TextStyle(
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
    _controller?.dispose();
    super.dispose();
  }
}
