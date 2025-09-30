import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const TermsConditionsScreen({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms & Conditions")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("You must agree to Luvvy's chat terms & conditions to continue.", style: TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton(
              child: const Text("I Agree & Chat"),
              onPressed: onAccept,
            ),
          ],
        ),
      ),
    );
  }
}
