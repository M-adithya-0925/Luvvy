import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ChooseGenderScreen.dart'; // Next screen
import 'services/FirebaseService.dart';

class BirthdayScreen extends StatefulWidget {
  final double progress;

  const BirthdayScreen({super.key, required this.progress});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();

  void _validateAndProceed() async {
    String day = _dayController.text.trim();
    String month = _monthController.text.trim();
    String year = _yearController.text.trim();

    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    try {
      final birthDate = DateTime.parse(
        '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}',
      );
      final now = DateTime.now();
      if (birthDate.isAfter(now)) {
        _showSnackBar("You can't be born in the future!");
        return;
      }

      // ✅ Save birthday to Firestore
      await _firebaseService.updateBirthday(birthDate);

      // ✅ Navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
      );
    } catch (e) {
      _showSnackBar("Please enter a valid date");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
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
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 6,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF9B26FF)),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Let's celebrate you 🎂",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter your date of birth to help us match you better.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateField(
                        controller: _monthController,
                        hint: "MM",
                        label: "Month"),
                    _buildDateField(
                        controller: _dayController, hint: "DD", label: "Day"),
                    _buildDateField(
                        controller: _yearController,
                        hint: "YYYY",
                        label: "Year",
                        maxLength: 4),
                  ],
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
              onPressed: _validateAndProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8000FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required String label,
    int maxLength = 2,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxLength),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
