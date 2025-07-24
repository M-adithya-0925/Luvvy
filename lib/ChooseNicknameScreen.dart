import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BirthdayScreen.dart';
import 'services/FirebaseService.dart';





class ChooseNicknameScreen extends StatefulWidget {
  const ChooseNicknameScreen({super.key});

  @override
  State<ChooseNicknameScreen> createState() => _ChooseNicknameScreenState();
}

class _ChooseNicknameScreenState extends State<ChooseNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> saveNickname(String nickname) async {
    await _firebaseService.updateNickname(nickname);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  value: 0.25,
                  minHeight: 6,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF9B26FF)),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Your datify identity 😎",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Create a unique nickname that represents you.\nIt's how others will know and remember you.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: "Nickname",
                    hintStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
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
              ),
              const SizedBox(height: 16),
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
            onPressed: () async {
              String nickname = _nicknameController.text.trim();
              if (nickname.isNotEmpty) {
                await saveNickname(nickname);

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BirthdayScreen(progress: 0.5)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a nickname")),
                );
              }
            },
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
    );
  }
}
