import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BirthdayScreen.dart';
import 'services/FirebaseService.dart';

class ChooseNicknameScreen extends StatefulWidget {
  const ChooseNicknameScreen({super.key});

  @override
  State<ChooseNicknameScreen> createState() => _ChooseNicknameScreenState();
}

class _ChooseNicknameScreenState extends State<ChooseNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  String? _availabilityMessage;
  Color? _messageColor;
  bool _migrationChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAndMigrateIfNeeded();
    // _debugCollections(); // Uncomment this for debugging
  }

  // ✅ Debug method - uncomment to see what's in your database
  Future<void> _debugCollections() async {
    try {
      print("🔍 DEBUG: Checking collections...");

      // Check users collection
      final users = await FirebaseFirestore.instance
          .collection('users')
          .limit(10)
          .get();
      print("👥 Users collection has ${users.docs.length} documents");
      for (final doc in users.docs) {
        final data = doc.data();
        print("  - User ${doc.id}: nickname = ${data['nickname']}, email = ${data['email']}");
      }

      // Check nicknames collection
      final nicknames = await FirebaseFirestore.instance
          .collection('nicknames')
          .limit(10)
          .get();
      print("📝 Nicknames collection has ${nicknames.docs.length} documents");
      for (final doc in nicknames.docs) {
        print("  - Nickname ${doc.id}: ${doc.data()}");
      }
    } catch (e) {
      print("❌ Debug error: $e");
    }
  }

  // ✅ Check if migration is needed and perform it
  Future<void> _checkAndMigrateIfNeeded() async {
    if (_migrationChecked) return;

    try {
      // Check if nicknames collection has any documents
      final nicknamesSnapshot = await FirebaseFirestore.instance
          .collection('nicknames')
          .limit(1)
          .get();

      if (nicknamesSnapshot.docs.isEmpty) {
        print("🔄 Nicknames collection is empty, checking for migration...");
        await _migrateExistingNicknames();
      } else {
        print("✅ Nicknames collection already populated");
      }

      _migrationChecked = true;
    } catch (e) {
      print("⚠️ Migration check failed: $e");
      _migrationChecked = true; // Don't keep retrying
    }
  }

  // ✅ Migration method to move existing nicknames to dedicated collection
  Future<void> _migrateExistingNicknames() async {
    try {
      print("🔄 Starting nickname migration...");

      // Get all users with nicknames
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get(); // Get all users to check for nicknames

      print("👥 Found ${usersSnapshot.docs.length} total users");

      final batch = FirebaseFirestore.instance.batch();
      int migratedCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final nickname = userData['nickname'] as String?;

        if (nickname != null && nickname.isNotEmpty) {
          final normalizedNickname = nickname.toLowerCase().trim();

          // Create nickname document
          final nicknameRef = FirebaseFirestore.instance
              .collection('nicknames')
              .doc(normalizedNickname);

          // Check if it already exists
          final existingNickname = await nicknameRef.get();
          if (!existingNickname.exists) {
            batch.set(nicknameRef, {
              'uid': userDoc.id,
              'originalNickname': nickname, // Keep original casing
              'createdAt': FieldValue.serverTimestamp(),
              'migratedAt': FieldValue.serverTimestamp(),
            });
            migratedCount++;
            print("📝 Migrating: '$nickname' -> '$normalizedNickname' (User: ${userDoc.id})");
          } else {
            print("⚠️ Nickname '$normalizedNickname' already exists in nicknames collection");
          }
        }
      }

      if (migratedCount > 0) {
        await batch.commit();
        print("✅ Migration completed: $migratedCount nicknames migrated");
      } else {
        print("ℹ️ No nicknames to migrate");
      }

    } catch (e) {
      print("❌ Migration error: $e");
    }
  }

  // ✅ Validate nickname format
  String? _validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return "Nickname is required";
    }
    if (nickname.length < 3) {
      return "Nickname must be at least 3 characters";
    }
    if (nickname.length > 20) {
      return "Nickname must be less than 20 characters";
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(nickname)) {
      return "Only letters, numbers, and underscores allowed";
    }
    return null;
  }

  // ✅ Enhanced availability check - checks both collections
  Future<bool> _checkNicknameAvailability(String nickname) async {
    if (nickname.trim().isEmpty) return false;

    // Validate format first
    final validationError = _validateNickname(nickname.trim());
    if (validationError != null) {
      setState(() {
        _isCheckingAvailability = false;
        _availabilityMessage = "✗ $validationError";
        _messageColor = Colors.red;
      });
      return false;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availabilityMessage = "Checking availability...";
      _messageColor = Colors.orange;
    });

    try {
      final normalizedNickname = nickname.toLowerCase().trim();

      print("🔍 Checking nickname availability: '$normalizedNickname'");

      // ✅ FIXED: Check both collections sequentially
      // Check nicknames collection
      final nicknameDoc = await FirebaseFirestore.instance
          .collection('nicknames')
          .doc(normalizedNickname)
          .get();

      // Check users collection as backup/verification
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: normalizedNickname)  // ✅ FIXED: Use isEqualTo
          .limit(1)
          .get();

      // Debug logging
      print("📊 Availability check results:");
      print("  - Nicknames collection: ${nicknameDoc.exists ? 'EXISTS' : 'NOT FOUND'}");
      print("  - Users collection: ${usersQuery.docs.length} matches");

      if (nicknameDoc.exists) {
        final data = nicknameDoc.data() as Map<String, dynamic>?;
        print("  - Nickname data: $data");
      }

      // Available only if not found in either collection
      final isAvailable = !nicknameDoc.exists && usersQuery.docs.isEmpty;

      setState(() {
        _isCheckingAvailability = false;
        if (isAvailable) {
          _availabilityMessage = "✓ Nickname is available!";
          _messageColor = Colors.green;
        } else {
          _availabilityMessage = "✗ Nickname is already taken";
          _messageColor = Colors.red;
        }
      });

      print("🎯 Final result: ${isAvailable ? 'AVAILABLE' : 'TAKEN'}");
      return isAvailable;

    } catch (e) {
      print("❌ Error checking availability: $e");
      setState(() {
        _isCheckingAvailability = false;
        _availabilityMessage = "Error checking availability - Please try again";
        _messageColor = Colors.red;
      });
      return false;
    }
  }

  // ✅ Save nickname with atomic batch operation
  Future<void> _saveNickname(String nickname) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate format
      final validationError = _validateNickname(nickname);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user logged in");
      }

      final normalizedNickname = nickname.toLowerCase().trim();
      print("💾 Saving nickname: '$nickname' -> '$normalizedNickname'");

      // Use batch write for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // Reference to nickname document
      final nicknameRef = FirebaseFirestore.instance
          .collection('nicknames')
          .doc(normalizedNickname);

      // Reference to user document
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);

      // ✅ FIXED: Triple-check availability before saving (sequential calls)
      final nicknameDoc = await nicknameRef.get();
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: normalizedNickname)  // ✅ FIXED: Use isEqualTo
          .limit(1)
          .get();

      if (nicknameDoc.exists || usersQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This nickname was just taken by another user. Please choose a different one."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create nickname document
      batch.set(nicknameRef, {
        'uid': currentUser.uid,
        'originalNickname': nickname.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user document
      batch.update(userRef, {
        'nickname': normalizedNickname,
        'displayNickname': nickname.trim(),
        'nicknameUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();
      print("✅ Nickname saved successfully");

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nickname '$nickname' saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BirthdayScreen(progress: 0.5)),
      );

    } catch (e) {
      print("❌ Error saving nickname: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving nickname: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 6,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF9B26FF)),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Your datify identity 😎",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Create a unique nickname that represents you.\nIt's how others will know and remember you.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                "• 3-20 characters\n• Letters, numbers, and underscores only\n• Must be unique",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _nicknameController,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Nickname",
                        hintStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _isCheckingAvailability
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Color(0xFF8000FF)),
                            ),
                          ),
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        if (_availabilityMessage != null) {
                          setState(() {
                            _availabilityMessage = null;
                            _messageColor = null;
                          });
                        }
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _checkNicknameAvailability(value.trim());
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Availability message
                    if (_availabilityMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _messageColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _messageColor?.withOpacity(0.3) ?? Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_isCheckingAvailability)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Icon(
                                _messageColor == Colors.green
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color: _messageColor,
                                size: 16,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _availabilityMessage!,
                                style: TextStyle(
                                  color: _messageColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Check availability button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isCheckingAvailability ? null : () {
                          final nickname = _nicknameController.text.trim();
                          if (nickname.isNotEmpty) {
                            _checkNicknameAvailability(nickname);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a nickname first")),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isCheckingAvailability
                                ? Colors.grey
                                : const Color(0xFF8000FF),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isCheckingAvailability
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.grey),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text("Checking...", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                            : const Text(
                          "Check Availability",
                          style: TextStyle(color: Color(0xFF8000FF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || _isCheckingAvailability) ? null : () {
              final nickname = _nicknameController.text.trim();
              if (nickname.isNotEmpty) {
                _saveNickname(nickname);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a nickname")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (_isLoading || _isCheckingAvailability)
                  ? Colors.grey
                  : const Color(0xFF8000FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: _isLoading ? 0 : 2,
            ),
            child: _isLoading
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Saving...",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            )
                : const Text(
              "Continue",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
