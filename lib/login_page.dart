import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'guest_main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Apple Sign-In Implementation
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Update user display name if available from Apple
      if (userCredential.user != null &&
          appleCredential.givenName != null &&
          appleCredential.familyName != null) {

        final displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
        await userCredential.user!.updateDisplayName(displayName);
      }

      // Navigate to main page after successful login
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Apple Sign-In Error: ${e.toString()}');
      }
    }
  }

  // Facebook Sign-In Implementation
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      // Trigger the Facebook sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Sign in with Firebase using the Facebook credential
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        // Get additional user data from Facebook
        final userData = await FacebookAuth.instance.getUserData();

        // Update user profile with Facebook data if needed
        if (userCredential.user != null && userData['name'] != null) {
          await userCredential.user!.updateDisplayName(userData['name']);

          // Update photo URL if available
          if (userData['picture'] != null && userData['picture']['data'] != null) {
            final photoUrl = userData['picture']['data']['url'];
            await userCredential.user!.updatePhotoURL(photoUrl);
          }
        }

        // Navigate to main page after successful login
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        if (context.mounted) {
          _showErrorDialog(context, 'Facebook login was cancelled by user');
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Facebook login failed: ${loginResult.message}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Facebook Sign-In Error: ${e.toString()}');
      }
    }
  }

  // Guest Mode Implementation
  Future<void> _startGuestMode(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.setInt('guest_swipe_count', 0);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GuestMainPage(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Error starting guest mode: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        icon: Icon(icon, color: color, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo and Title
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Datify",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Let's dive into your account!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 48),

              // Social Login Buttons
              // Google Sign-In (keeping your existing logic)
              buildSocialButton(
                context,
                "Continue with Google",
                Icons.g_mobiledata,
                Colors.red,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Apple Sign-In (new implementation)
              buildSocialButton(
                context,
                "Continue with Apple",
                Icons.apple,
                Colors.black,
                    () => _signInWithApple(context),
              ),
              const SizedBox(height: 12),

              // Facebook Sign-In (new implementation)
              buildSocialButton(
                context,
                "Continue with Facebook",
                Icons.facebook,
                Colors.blue,
                    () => _signInWithFacebook(context),
              ),

              const SizedBox(height: 24),

              // Email Login Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Log in with Email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Guest Mode Button
              TextButton(
                onPressed: () => _startGuestMode(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Continue as Guest",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
