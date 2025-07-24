import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Make sure these paths are correct based on your project structure
import 'ChooseInterest.dart';
import 'InterestsSelectionScreen.dart'; // Should have a valid constructor that takes `preferences`
import 'package:luvvy/services/FirebaseService.dart'; // ✅ Correct path

class ProfileStoryScreen extends StatefulWidget {
  const ProfileStoryScreen({super.key});

  @override
  State<ProfileStoryScreen> createState() => _ProfileStoryScreenState();
}

class _ProfileStoryScreenState extends State<ProfileStoryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> sendStoryToBackend(String story) async {
    final uri = Uri.parse('http://192.168.1.25:5000/analyze');
    setState(() => _isLoading = true);

    try {
      // ✅ Save to Firestore using FirebaseService
      await FirebaseService().updateStory(story);

      // ✅ Send story to Flask backend
      final response = await http.post(uri, body: {'about_me': story});
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("✅ Preferences from backend: $result");

        // ✅ Navigate to InterestsSelectionScreen with preferences
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InterestsSelectionScreen(preferences: result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to server.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tell your story"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Describe yourself",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "I love hiking, movies, and exploring new cultures...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                String story = _controller.text.trim();
                if (story.isNotEmpty) {
                  sendStoryToBackend(story);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please write your story.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
