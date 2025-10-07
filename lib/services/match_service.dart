import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchService {
  static const String baseUrl = 'http://192.168.1.27:5000';

  static Future<List<Map<String, dynamic>>> getRecommendations(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommend?email=$email'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting recommendations: $e');
      rethrow;
    }
  }

  static Future<List<String>> getMyMatches(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my_matches?email=$email'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> matches = data['matches'] ?? [];
        return matches.cast<String>();
      } else {
        throw Exception('Failed to get matches: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting matches: $e');
      rethrow;
    }
  }
}
