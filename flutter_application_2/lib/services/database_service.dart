import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Use localhost for web, 10.0.2.2 for Android emulator, or your machine's IP for physical devices
  final String apiBaseUrl = 'http://localhost:4567/api';

  Future<bool> registerUser(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Registration error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Login error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // Lưu lịch trình mới 
  Future<bool> saveSchedule(int userId, Map<String, dynamic> schedule) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/schedules'),
        headers: headers,
        body: jsonEncode({
          'title': schedule['title'],
          'description': schedule['description'],
          'tags': _normalizeTags(schedule['tags']),
          'priority': schedule['priority'],
          'deadline': _normalizeDate(schedule['deadline']),
          'is_completed': _normalizeIsCompleted(schedule),
        }),
      );
      debugPrint('Save schedule response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Save schedule error: $e');
      return false;
    }
  }

  // Lấy danh sách lịch trình của user
  Future<List<Map<String, dynamic>>> getSchedules(int userId) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/schedules/$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('Get schedules error: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Get schedules error: $e');
      return [];
    }
  }

  // Cập nhật lịch trình
  Future<bool> updateSchedule(int scheduleId, Map<String, dynamic> schedule) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/schedules/$scheduleId'),
        headers: headers,
        body: jsonEncode({
          'title': schedule['title'],
          'description': schedule['description'],
          'tags': _normalizeTags(schedule['tags']),
          'priority': schedule['priority'],
          'deadline': _normalizeDate(schedule['deadline']),
          'is_completed': _normalizeIsCompleted(schedule),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update schedule error: $e');
      return false;
    }
  }

  // Xóa lịch trình
  Future<bool> deleteSchedule(int scheduleId) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/schedules/$scheduleId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete schedule error: $e');
      return false;
    }
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String _normalizeTags(dynamic tags) {
    if (tags is List) {
      return tags.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).join(',');
    }
    return tags?.toString() ?? '';
  }

  String? _normalizeDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toIso8601String();
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  bool _normalizeIsCompleted(Map<String, dynamic> schedule) {
    final value = schedule['is_completed'] ?? schedule['isCompleted'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }
}