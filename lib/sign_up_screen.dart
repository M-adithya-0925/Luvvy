import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChooseNicknameScreen.dart'; // Make sure this import is correct

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("🔄 Starting signup process...");

      // Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;
      print("✅ Firebase Auth successful. UID: $uid");

      // Save user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'createdAt': DateTime.now(),
      });

      print("✅ User created and stored in Firestore");

      if (!mounted) {
        print("⚠️ Widget not mounted, returning");
        return;
      }

      print("🔄 About to navigate...");

      // Simple navigation - try this first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChooseNicknameScreen(),
        ),
      );

      print("✅ Navigation executed");

    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Signup failed")),
        );
      }
    } catch (e) {
      print("❌ General Error: $e");
      print("❌ Error Type: ${e.runtimeType}");
      print("❌ Stack trace: ${StackTrace.current}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),



              const SizedBox(height: 10),
              const Text(
                "Create an account 🧑‍💻",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create your account in seconds. We'll help you\nfind your perfect match.",
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 30),

              const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: const Icon(Icons.visibility_off_outlined),
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Colors.purple),
                    activeColor: Colors.purple,
                  ),
                  const Text("I agree to Datify "),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Privacy Policy.",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Sign up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}