import 'package:flutter/material.dart';
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
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isNavigating = false;
  bool _showMoreOptions = false;

  final List<String> moreGenderOptions = [
    'Non-binary',
    'Transgender',
    'Genderfluid',
    'Agender',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.5,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
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

  Future<void> _saveGenderToFirestore(String gender) async {
    await FirebaseService().updateGender(gender);
  }

  void _handleContinue() async {
    if (selectedGender != null && !_isNavigating) {
      setState(() {
        _isNavigating = true;
      });

      await _progressController.forward();

      await _saveGenderToFirestore(selectedGender!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RelationshipGoalsScreen(),
          ),
        );
        setState(() => _isNavigating = false);
        _progressController.reset();
      }
    }
  }

  Widget _buildGenderOption(String gender, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8000FF) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF8000FF) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOption() {
    return GestureDetector(
      onTap: _toggleMoreOptions,
      child: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "More",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _showMoreOptions
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_right,
                color: Colors.black,
                size: 24,
              ),
            ],
          ),
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
                      valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF9B26FF)),
                      backgroundColor: Colors.grey.shade300,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: const [
                  Text(
                    "Be true to yourself ",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text("✨", style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose the gender that best represents you.\nAuthenticity is key to meaningful connections.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGenderOption("Man",
                          isSelected: selectedGender == "Man"),
                      _buildGenderOption("Woman",
                          isSelected: selectedGender == "Woman"),
                      _buildMoreOption(),
                      if (_showMoreOptions) ...[
                        const SizedBox(height: 8),
                        ...moreGenderOptions.map(
                              (option) => _buildGenderOption(option,
                              isSelected: selectedGender == option),
                        ),
                      ],
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
            onPressed: selectedGender != null && !_isNavigating
                ? _handleContinue
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedGender != null && !_isNavigating
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
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
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
