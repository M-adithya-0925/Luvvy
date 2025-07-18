import 'package:flutter/material.dart';
import 'package:luvvy/ChooseNicknameScreen.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              // Email Icon Circle
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Check Your Email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We have sent an email to\nand********ley@yourdomain.com.\nClick the link inside to get started.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Resend email logic
                },
                child: const Text(
                  "Resend email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9B26FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ChooseNicknameScreen(),));
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF9B26FF), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    "I've verified my email",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9B26FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
