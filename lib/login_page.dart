import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget buildSocialButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.6,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Color(0xFF9610FF), size: 60),
            const SizedBox(height: 16),
            const Text(
              "Luvvy",
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 1.6,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Let’s dive in into your account!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w400,
                fontSize: 18,
                height: 1.6,
                letterSpacing: 0.2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            buildSocialButton("Continue with Google", Icons.g_mobiledata, Colors.red),
            const SizedBox(height: 10),
            buildSocialButton("Continue with Apple", Icons.apple, Colors.black),
            const SizedBox(height: 10),
            buildSocialButton("Continue with Facebook", Icons.facebook, Colors.blue),
            const SizedBox(height: 10),
            buildSocialButton("Continue with Twitter", Icons.flutter_dash, Colors.lightBlue),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9610FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Log in",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.2,
                  height: 1.6,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: TextStyle(
                      color: Color(0xFF9610FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Guest mode",
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}