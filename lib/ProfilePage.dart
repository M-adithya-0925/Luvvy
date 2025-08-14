import 'package:flutter/material.dart';
class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('👤 Profile Details of $userId', style: TextStyle(fontSize: 20)),
    );
  }
}
