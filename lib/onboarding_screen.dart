import 'package:flutter/material.dart';
import 'login_page.dart';

const Color primaryColor = Color(0xFF9610FF);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "imagePath": "assets/matches.png",
      "title": "Discover Meaningful\nConnections",
      "subtitle":
      "Join Datify today and explore a world of meaningful connections. Swipe, match, and meet like-minded people.",
    },
    {
      "imagePath": "assets/profile.png",
      "title": "Be Yourself,\nStand Out from the Crowd.",
      "subtitle":
      "Tell your story. Share your interests, hobbies, and what you're looking for. Be authentic and make a lasting impression.",
    },
    {
      "imagePath": "assets/match.png",
      "title": "Find Your\nPerfect Match Today",
      "subtitle":
      "Discover real connections with Datify's intelligent matchmaking. Start swiping to find your perfect match today.",
    }
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
            currentPage: _currentPage,
            onContinue: _nextPage,
            onSkip: _skip,
          );
        },
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final int currentPage;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onContinue,
    required this.onSkip,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: media.height * 0.58,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFFB546E8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OverflowBox(
                  maxHeight: 800,
                  maxWidth: media.width,
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: const Offset(0,40),
                    child: Image.asset(
                      imagePath,
                      height: 800,
                      width: 390,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      letterSpacing: 0.2,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == currentPage ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == currentPage
                              ? primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onSkip,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5E6FA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.2,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.82);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.82);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
