import 'package:flutter/material.dart';

class LoginSuccessDialog extends StatelessWidget {
  const LoginSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9B26FF), // Purple
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.person, size: 60, color: Colors.white),
                // Optional: Add custom floating dots for particles if needed
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Log in Successful!',
              style: TextStyle(
                color: Color(0xFF9B26FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait...\nYou will be directed to the homepage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B26FF)),
              strokeWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}
