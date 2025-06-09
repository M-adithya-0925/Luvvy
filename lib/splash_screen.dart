import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _heartController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _heartController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  List<Widget> buildAnimatedHearts() {
    return List.generate(20, (index) {
      final size = 20.0 + _random.nextInt(40);
      final left = _random.nextDouble() * MediaQuery.of(context).size.width;
      final delay = _random.nextDouble() * 4;
      final topStart = MediaQuery.of(context).size.height + _random.nextInt(100);
      final topEnd = -100.0;

      return AnimatedBuilder(
        animation: _heartController,
        builder: (_, __) {
          final progress = (_heartController.value + delay) % 1.0;
          final top = topStart + (topEnd - topStart) * progress;

          return Positioned(
            top: top,
            left: left,
            child: Opacity(
              opacity: (1 - progress),
              child: Icon(Icons.favorite,
                  color: Colors.white.withOpacity(0.2), size: size),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9610FF),
      body: Stack(
        children: [
          ...buildAnimatedHearts(),
          Center(
            child: ScaleTransition(
              scale: Tween(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(Icons.chat_bubble, size: 80, color: Color(0xFF9610FF)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Luvvy",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white.withOpacity(0.8),
                        ),
                      );
                    },
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
