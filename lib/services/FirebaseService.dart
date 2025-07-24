import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateGender(String gender) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'gender': gender,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'interests': interests,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateDistanceRange(int distanceInKm) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'distancePreference': distanceInKm,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateProfileStory({
    required String name,
    required String bio,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'bio': bio,
        'profileImage': imageUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateNickname(String nickname) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'nickname': nickname,
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateBirthday(DateTime birthday) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'birthday': birthday.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveRelationshipGoal(String goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'relationshipGoal': goal,
      }, SetOptions(merge: true));
    }
  }


  /// ✅ Add this new method:
  Future<void> updateStory(String story) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'story': story,
      }, SetOptions(merge: true));
    }
  }
}
