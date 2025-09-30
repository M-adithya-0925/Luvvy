import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:luvvy/ChooseInterest.dart';
import 'package:luvvy/services/FirebaseService.dart';

class ProfileStoryScreen extends StatefulWidget {
  const ProfileStoryScreen({super.key});

  @override
  State<ProfileStoryScreen> createState() => _ProfileStoryScreenState();
}

class _ProfileStoryScreenState extends State<ProfileStoryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isAnalyzing = false;

  // Character limits
  final int _minCharacters = 50;
  final int _maxCharacters = 500;

  // Sample stories for inspiration
  final List<String> _sampleStories = [
    "I'm passionate about exploring new cultures and trying authentic cuisines. Weekend hikes and yoga sessions keep me centered. Love indie music and cozy bookstore adventures.",
    "Tech entrepreneur by day, salsa dancer by night! I enjoy cooking Italian food, binge-watching sci-fi shows, and planning spontaneous road trips with friends.",
    "Art lover who finds beauty in vintage photography and street art. I spend mornings journaling, afternoons at local cafes, and evenings learning guitar.",
  ];

  int get _characterCount => _controller.text.length;
  bool get _isValidLength => _characterCount >= _minCharacters && _characterCount <= _maxCharacters;

  Color get _counterColor {
    if (_characterCount < _minCharacters) return Colors.orange;
    if (_characterCount > _maxCharacters) return Colors.red;
    return Colors.green;
  }

  Color get _counterColorShade {
    if (_characterCount < _minCharacters) return Colors.orange.shade700;
    if (_characterCount > _maxCharacters) return Colors.red.shade700;
    return Colors.green.shade700;
  }

  Future<void> _sendStoryToBackend(String story) async {
    final uri = Uri.parse('http://192.168.1.48:5000/analyze');

    setState(() {
      _isLoading = true;
      _isAnalyzing = true;
    });

    try {
      // Save to Firestore first
      await FirebaseService().updateStory(story);

      // Send to backend for analysis
      final response = await http.post(
        uri,
        body: {'about_me': story},
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("✅ AI Analysis Result: $result");

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InterestsSelectionScreen(preferences: result),
            ),
          );
        }
      } else {
        _showErrorMessage("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Connection error: $e");
      _showErrorMessage("Unable to connect. Please check your internet connection.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _useSampleStory(String sample) {
    setState(() {
      _controller.text = sample;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress indicator
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.95,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Tell your story",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("✨", style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      "Share what makes you unique. Our AI will analyze your story to suggest perfect matches based on your interests and personality.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Character counter and requirements
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _counterColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _counterColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(_isValidLength ? Icons.check_circle : Icons.info_outline,
                              color: _counterColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isValidLength
                                ? "Perfect length! Ready to analyze"
                                : "Write $_minCharacters-$_maxCharacters characters",
                            style: TextStyle(
                              color: _counterColorShade,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$_characterCount/$_maxCharacters",
                            style: TextStyle(
                              color: _counterColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Text input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          expands: true,
                          maxLength: _maxCharacters,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                          decoration: InputDecoration(
                            hintText: "I'm passionate about art and love exploring new coffee shops on weekends. When I'm not working as a designer, you'll find me hiking trails or trying new recipes...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            counterText: "",
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sample stories (simplified)
                    Text(
                      "Need inspiration? Try these examples:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Simplified example buttons
                    Row(
                      children: _sampleStories.take(2).map((story) {
                        final index = _sampleStories.indexOf(story);
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                            child: ElevatedButton(
                              onPressed: () => _useSampleStory(story),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.purple.shade600,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Example ${index + 1}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValidLength && !_isLoading
                        ? () => _sendStoryToBackend(_controller.text.trim())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: _isValidLength && !_isLoading ? 2 : 0,
                    ),
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isAnalyzing ? "Analyzing your story..." : "Saving...",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      _isValidLength
                          ? "Analyze with AI ✨"
                          : "Write your story first",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isValidLength ? Colors.white : Colors.grey.shade500,
                      ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
