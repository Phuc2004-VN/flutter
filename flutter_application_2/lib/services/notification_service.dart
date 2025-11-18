import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/models/app_notification.dart';
import 'package:flutter_application_2/models/schedule.dart';
import 'package:flutter_application_2/providers/setting_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;

  final String baseUrl = 'http://localhost:4567/api';

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<int?> _userId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('logged_in_user_id');
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final userId = await _userId();
    if (userId == null) return [];
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AppNotification.fromJson(e)).toList();
      }
      debugPrint('Fetch notifications error: ${response.body}');
    } catch (e) {
      debugPrint('Fetch notifications exception: $e');
    }
    return [];
  }

  Future<void> createOrUpdateFromSchedule(Schedule schedule, String message, {String? priority}) async {
    final headers = await _authHeaders();
    final scheduleId = int.tryParse(schedule.id);
    if (scheduleId == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
        body: jsonEncode({
          'title': schedule.title,
          'content': message,
          'priority': priority,
          'scheduleId': scheduleId,
          'markAsUnread': true,
        }),
      );
    } catch (e) {
      debugPrint('Create notification error: $e');
    }
  }

  Future<void> markAsRead(int id, bool isRead) async {
    try {
      final headers = await _authHeaders();
      await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: headers,
        body: jsonEncode({'is_read': isRead}),
      );
    } catch (e) {
      debugPrint('Mark read error: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final headers = await _authHeaders();
      await http.delete(Uri.parse('$baseUrl/notifications/$id'), headers: headers);
    } catch (e) {
      debugPrint('Delete notification error: $e');
    }
  }

  Future<void> syncFromSchedules(
    List<Schedule> schedules,
    NotificationSettingsProvider settings,
  ) async {
    final headers = await _authHeaders();
    final userId = await _userId();
    if (userId == null) return;

    final existing = await fetchNotifications();
    final Map<int, AppNotification> byScheduleId = {
      for (final n in existing)
        if (n.scheduleId != null) n.scheduleId!: n
    };

    final now = DateTime.now();
    final remindBefore = settings.reminderBeforeDeadlineEnabled ? settings.reminderMinutesBefore : 0;

    for (final schedule in schedules) {
      final scheduleId = int.tryParse(schedule.id);
      if (scheduleId == null) continue;
      final deadline = schedule.deadline ??
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day, schedule.time.hour, schedule.time.minute);
      final remindTime = deadline.subtract(Duration(minutes: remindBefore));
      final bool shouldAlert = !schedule.isCompleted &&
          (settings.notificationEnabled &&
              (settings.reminderBeforeDeadlineEnabled ? remindTime.isBefore(now) : deadline.isBefore(now)));

      final existingNotification = byScheduleId[scheduleId];
      if (shouldAlert) {
        final message = settings.reminderBeforeDeadlineEnabled ? 'Lịch trình sắp diễn ra' : 'Lịch trình đã quá hạn';
        await createOrUpdateFromSchedule(schedule, message, priority: schedule.priority);
      } else if (existingNotification != null && !existingNotification.isRead) {
        try {
          await http.patch(
            Uri.parse('$baseUrl/notifications/${existingNotification.id}/read'),
            headers: headers,
            body: jsonEncode({'is_read': true}),
          );
        } catch (e) {
          debugPrint('Auto mark read error: $e');
        }
      }
    }
  }
}

