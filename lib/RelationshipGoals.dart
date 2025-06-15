import 'package:flutter/material.dart';
import 'package:luvvy/DistanceRange.dart';

class RelationshipGoalsScreen extends StatefulWidget {
  const RelationshipGoalsScreen({super.key});

  @override
  State<RelationshipGoalsScreen> createState() => _RelationshipGoalsScreenState();
}

class _RelationshipGoalsScreenState extends State<RelationshipGoalsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedGoal;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _selectGoal(String goal) {
    setState(() {
      selectedGoal = goal;
    });
  }

  void _handleContinue() async {
    if (selectedGoal != null && !_isNavigating) {
      setState(() {
        _isNavigating = true;
      });

      // Start progress bar animation
      await _progressController.forward();

      // Navigate to next screen after animation completes
      if (mounted) {
        // Replace with your next screen navigation
        print("Selected relationship goal: $selectedGoal");
        Navigator.push(context, MaterialPageRoute(builder: (context) => DistancePreferenceScreen()));
        
        // Reset state when returning (for demo purposes)
        setState(() {
          _isNavigating = false;
        });
        _progressController.reset();
      }
    }
  }

  Widget _buildGoalOption({
    required String title,
    required String emoji,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectGoal(title),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8000FF) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      minHeight: 6,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF9B26FF)),
                      backgroundColor: Colors.grey.shade300,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Title with emoji
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Your relationship goals ",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                    "💘",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                "Choose the type of relationship you're seeking on Datify. Love, friendship, or something in between—it's your choice.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Relationship options
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGoalOption(
                        title: "Dating",
                        emoji: "💃",
                        description: "Seeking love and meaningful connections? Choose dating for genuine relationships.",
                        isSelected: selectedGoal == "Dating",
                      ),
                      _buildGoalOption(
                        title: "Friendship",
                        emoji: "🙌",
                        description: "Expand your social circle and make new friends. Opt for friendship today.",
                        isSelected: selectedGoal == "Friendship",
                      ),
                      _buildGoalOption(
                        title: "Casual",
                        emoji: "😊",
                        description: "Looking for fun and relaxed encounters? Select casual for carefree connections.",
                        isSelected: selectedGoal == "Casual",
                      ),
                      _buildGoalOption(
                        title: "Serious Relationship",
                        emoji: "💍",
                        description: "Ready for commitment and a lasting partnership? Pick serious relationship.",
                        isSelected: selectedGoal == "Serious Relationship",
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedGoal != null && !_isNavigating ? _handleContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedGoal != null && !_isNavigating
                  ? const Color(0xFF8000FF)
                  : const Color(0xFF8000FF).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: _isNavigating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
}