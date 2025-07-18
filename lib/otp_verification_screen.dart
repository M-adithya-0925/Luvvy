import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'create_new_password_screen.dart';


class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // Title
              const Text(
                'OTP code verification 🔒',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'We have sent an OTP code to your email\nand********ley@yourdomain.com. Enter the OTP code below to verify.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              // OTP Code Input
              PinCodeTextField(
                appContext: context,
                length: 4,
                onChanged: (value) {
                  if (value.length == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateNewPasswordScreen()),
                    );
                  }
                },
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  selectedColor: Colors.purple,
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey.shade300,
                  inactiveFillColor: Colors.grey.shade100,
                  activeColor: Colors.purple,
                  activeFillColor: Colors.white,
                ),
                enableActiveFill: true,
              ),

              const SizedBox(height: 20),

              // Didn't receive email
              const Center(
                child: Text("Didn't receive email?"),
              ),
              const SizedBox(height: 4),

              // Resend Code Countdown
              Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'You can resend code in ',
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: '52 s',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
