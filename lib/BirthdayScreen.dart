import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChooseGenderScreen.dart';
import 'services/FirebaseService.dart';

class BirthdayScreen extends StatefulWidget {
  final double progress;

  const BirthdayScreen({super.key, required this.progress});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime? _selectedDate;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _isDeleting = false;

  // ✅ Calculate age from birth date
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Check if birthday hasn't occurred this year yet
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ✅ Show calendar date picker
  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final DateTime hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: hundredYearsAgo, // Maximum 100 years old
      lastDate: now, // Cannot select future dates
      helpText: 'Select your birth date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      fieldLabelText: 'Birth Date',
      fieldHintText: 'MM/DD/YYYY',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF8000FF), // Purple theme
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Auto-validate age when date is selected
      _validateAge();
    }
  }

  // ✅ Validate age and show appropriate UI
  void _validateAge() {
    if (_selectedDate == null) return;

    final age = _calculateAge(_selectedDate!);

    if (age < 18) {
      _showUnderageDialog(age);
    } else {
      _showSnackBar(
        "Great! You're $age years old. Ready to continue?",
        Colors.green,
      );
    }
  }

  // ✅ Show underage dialog with account deletion option
  void _showUnderageDialog(int age) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Age Restriction',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sorry, you must be at least 18 years old to use this app.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your account will be permanently deleted for safety reasons.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedDate = null; // Reset selection
                });
              },
              child: const Text('Choose Different Date'),
            ),
            ElevatedButton(
              onPressed: _isDeleting ? null : _deleteAccountAndExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isDeleting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Delete Account',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Delete user account and all associated data
  Future<void> _deleteAccountAndExit() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      print("🗑️ Deleting account for underage user: ${user.uid}");

      // Delete user data from Firestore first
      final batch = FirebaseFirestore.instance.batch();

      // Delete from users collection
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.delete(userRef);

      // Delete from nicknames collection if nickname exists
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final nickname = userData?['nickname'] as String?;
        if (nickname != null) {
          final nicknameRef = FirebaseFirestore.instance
              .collection('nicknames')
              .doc(nickname.toLowerCase());
          batch.delete(nicknameRef);
        }
      }

      // Commit batch deletion
      await batch.commit();
      print("✅ Firestore data deleted");

      // Delete Firebase Auth account
      await user.delete();
      print("✅ Firebase Auth account deleted");

      if (!mounted) return;

      // Navigate back to login/signup
      Navigator.of(context).popUntil((route) => route.isFirst);

      _showSnackBar(
        "Account deleted successfully. You must be 18+ to use this app.",
        Colors.red,
      );

    } catch (e) {
      print("❌ Error deleting account: $e");

      if (!mounted) return;

      // If account deletion fails, still exit the app
      Navigator.of(context).popUntil((route) => route.isFirst);

      _showSnackBar(
        "Please contact support. You must be 18+ to use this app.",
        Colors.red,
      );
    }
  }

  // ✅ Validate and proceed to next screen
  Future<void> _validateAndProceed() async {
    if (_selectedDate == null) {
      _showSnackBar("Please select your birth date", Colors.red);
      return;
    }

    final age = _calculateAge(_selectedDate!);

    if (age < 18) {
      _validateAge(); // This will show the underage dialog
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Save birthday as Timestamp (proper format)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'birthday': Timestamp.fromDate(_selectedDate!),
        'age': age, // Denormalized for efficient queries
        'birthdayUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Also update via FirebaseService if needed
      await _firebaseService.updateBirthday(_selectedDate!);

      if (!mounted) return;

      // ✅ Navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
      );

    } catch (e) {
      print("❌ Error saving birthday: $e");
      _showSnackBar("Error saving birthday. Please try again.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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

              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 8),

              // Progress indicator
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

              // Title
              const Text(
                "Let's celebrate you 🎂",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "Enter your date of birth. You must be 18+ to use this app.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 8),

              // Age requirement notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Accounts under 18 will be automatically deleted",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Calendar selection card
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Calendar icon and selected date display
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 48,
                              color: _selectedDate != null
                                  ? const Color(0xFF8000FF)
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),

                            if (_selectedDate != null) ...[
                              Text(
                                "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8000FF),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Age: ${_calculateAge(_selectedDate!)} years",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else ...[
                              Text(
                                "Tap to select your birth date",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Select date button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _selectDate,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8000FF), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF8000FF),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? "Select Birth Date"
                                    : "Change Date",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8000FF),
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
            ],
          ),
        ),
      ),

      // Continue button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || _selectedDate == null)
                ? null
                : _validateAndProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedDate != null && !_isLoading
                  ? const Color(0xFF8000FF)
                  : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: _selectedDate != null ? 2 : 0,
            ),
            child: _isLoading
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Saving...",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            )
                : Text(
              "Continue",
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
