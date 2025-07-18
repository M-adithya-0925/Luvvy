import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChooseInterest.dart';
import 'InterestsSelectionScreen.dart'; // Navigate here with preferences

class ProfileStoryScreen extends StatefulWidget {
  @override
  _ProfileStoryScreenState createState() => _ProfileStoryScreenState();
}

class _ProfileStoryScreenState extends State<ProfileStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> sendStoryToBackend(String story) async {
    final uri = Uri.parse('http://192.168.0.229:5000/analyze');
    // Update IP if needed

    setState(() => _isLoading = true);

    try {
      final response = await http.post(uri, body: {'about_me': story});

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("✅ Preferences: $result");

        // Navigate to InterestsSelectionScreen with backend preferences
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
        SnackBar(content: Text("Failed to connect to server.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomInset + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.8,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60),

                    // Title
                    Text(
                      'Your story, your spark',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Description
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                        children: [
                          TextSpan(
                            text:
                            'Tell us about yourself — your story, your spark, what makes you you. We\'ll help you find someone who truly gets it.',
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('💫', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Prompt
                    Text(
                      'Tell us about yourself...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Story input
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF8B5CF6), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
                        decoration: InputDecoration(
                          hintText:
                          'Share your story, interests, what makes you unique...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    String story = _textController.text.trim();
                    if (story.isNotEmpty) {
                      sendStoryToBackend(story);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please tell us about yourself first!'),
                          backgroundColor: Color(0xFF8B5CF6),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
