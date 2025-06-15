import 'package:flutter/material.dart';
import 'login.dart'; // Make sure this points to the file with LoginScreen class

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Fix: define buildSocialButton properly
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
      label: Text(label),
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
          children: [
            const Icon(Icons.favorite, color: Colors.purple, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Datify",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Let’s dive into your account!",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 40),
            buildSocialButton("Continue with Google", Icons.g_mobiledata, Colors.red),
            const SizedBox(height: 10),
            buildSocialButton("Continue with Apple", Icons.apple, Colors.black),
            const SizedBox(height: 10),
            buildSocialButton("Continue with Facebook", Icons.facebook, Colors.blue),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to actual login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Log in"),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                text: "Don't have an account? ",
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Guest mode logic here
              },
              child: const Text("Guest mode"),
            )
          ],
        ),
      ),
    );
  }
}
