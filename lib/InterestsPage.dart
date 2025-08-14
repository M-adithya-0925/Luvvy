import 'package:flutter/material.dart';
class InterestsPage extends StatelessWidget {
  final String userId;
  const InterestsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('❤ Your Interests (user: $userId)', style: TextStyle(fontSize: 20)),
    );
  }
}