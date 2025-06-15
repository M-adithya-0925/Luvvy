import 'package:flutter/material.dart';
import 'package:luvvy/login.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool progressBar;
  final bool confetti;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onContinue,
    required this.onSkip,
    this.progressBar = false,
    this.confetti = false,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (progressBar)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("15%",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          const SizedBox(height: 30),
          // Phone frame mockup
          Container(
            height: media.height * 0.45,
            width: media.width * 0.8,
            decoration: BoxDecoration(
              border: Border.all(width: 8, color: Colors.black),
              borderRadius: BorderRadius.circular(40),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 30),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              )),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: onSkip,
                  child: const Text("Skip",
                      style: TextStyle(color: Colors.purple))),
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 25, 223),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Continue",
                style:TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "imagePath": "assets/matches.png",
      "title": "Discover Meaningful Connections",
      "subtitle": "Join Datify today and explore a world of meaningful connections. Swipe, match, and meet like-minded people.",
    },
    {
      "imagePath": "assets/profile.png",
      "title": "Be Yourself, Stand Out from the Crowd.",
      "subtitle": "Tell your story. Share your interests, hobbies and what you're looking for. Be authentic and make a lasting impression.",
      "progressBar": true,
    },
    {
      "imagePath": "assets/match.png",
      "title": "Find Your Perfect Match Today",
      "subtitle": "Discover real connections with Datify’s intelligent matchmaking. Start swiping to find your perfect match today.",
      "confetti": true,
    }
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _skip() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final data = pages[index];
          return OnboardingPage(
            imagePath: data["imagePath"],
            title: data["title"],
            subtitle: data["subtitle"],
            progressBar: data["progressBar"] ?? false,
            confetti: data["confetti"] ?? false,
            onContinue: _nextPage,
            onSkip: _skip,
          );
        },
      ),
    );
  }
}
