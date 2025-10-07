// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.27:5000';

  // Send like to another user
  static Future<bool> likeUser(String likerEmail, String likedEmail, double matchScore) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'liker_email': likerEmail,
          'liked_email': likedEmail,
          'match_score': matchScore,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Error liking user: $e');
      return false;
    }
  }

  // Accept a like (create match)
  static Future<Map<String, dynamic>?> acceptLike(String accepterEmail, String originalLikerEmail, String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accept_like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accepter_email': accepterEmail,
          'original_liker_email': originalLikerEmail,
          'notification_id': notificationId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ Error accepting like: $e');
      return null;
    }
  }

  // Reject a like
  static Future<bool> rejectLike(String rejectorEmail, String originalLikerEmail, String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reject_like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rejector_email': rejectorEmail,
          'original_liker_email': originalLikerEmail,
          'notification_id': notificationId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error rejecting like: $e');
      return false;
    }
  }

  // Get user notifications
  static Future<List<Map<String, dynamic>>> getNotifications(String userEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications/$userEmail'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  // Get user matches
  static Future<List<Map<String, dynamic>>> getMatches(String userEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matches/$userEmail'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['matches'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Error getting matches: $e');
      return [];
    }
  }
}
