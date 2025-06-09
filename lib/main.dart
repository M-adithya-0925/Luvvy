import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_page.dart';

void main() {
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF9610FF)),
      ),
      home: const SplashScreen(),
    );
  }
}
