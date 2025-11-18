import 'package:intl/intl.dart';

class AppNotification {
  final int id;
  final int userId;
  final int? scheduleId;
  final String title;
  final String? content;
  final String? priority;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.scheduleId,
    required this.title,
    this.content,
    this.priority,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'],
      scheduleId: json['schedule_id'] == null
          ? null
          : (json['schedule_id'] is String ? int.tryParse(json['schedule_id']) : json['schedule_id']),
      title: json['title'] ?? '',
      content: json['content'],
      priority: json['priority'],
      isRead: (json['is_read'] is bool)
          ? json['is_read']
          : (json['is_read'] is num ? json['is_read'] != 0 : (json['is_read']?.toString().toLowerCase() == 'true')),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'schedule_id': scheduleId,
      'title': title,
      'content': content,
      'priority': priority,
      'is_read': isRead,
      'created_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt),
    };
  }
}

