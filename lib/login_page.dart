import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import your LoginScreen
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget buildSocialButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
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
            const Text("Datify",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            const Text("Let’s dive into your account!",
                style: TextStyle(fontSize: 16, color: Colors.black54)),

            const SizedBox(height: 40),
            buildSocialButton(
              context,
              "Continue with Google",
              Icons.g_mobiledata,
              Colors.red,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            buildSocialButton(context, "Continue with Apple", Icons.apple, Colors.black, () {}),
            const SizedBox(height: 10),
            buildSocialButton(context, "Continue with Facebook", Icons.facebook, Colors.blue, () {}),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
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
            const TextButton(onPressed: null, child: Text("Guest mode"))
          ],
        ),
      ),
    );
  }
}
