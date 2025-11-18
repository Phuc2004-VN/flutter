import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class Schedule {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay time;
  final List<String> tags;
  final List<Map<String, String>> attachments;
  final bool isCompleted;
  final String? priority;
  final DateTime? deadline;
  final String? workspaceId;

  Schedule({
    String? id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.tags,
    this.attachments = const [],
    this.isCompleted = false,
    this.priority,
    this.deadline,
    this.workspaceId,
  }) : id = id ?? const Uuid().v4();

  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    List<String>? tags,
    List<Map<String, String>>? attachments,
    bool? isCompleted,
    String? priority,
    DateTime? deadline,
    String? workspaceId,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'tags': tags,
      'attachments': attachments,
      'isCompleted': isCompleted,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'workspaceId': workspaceId,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      description: json['description'] as String?,
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(':')[0]),
        minute: int.parse(json['time'].split(':')[1]),
      ),
      tags: List<String>.from(json['tags']),
      attachments: List<Map<String, String>>.from(
          (json['attachments'] as List? ?? []).map((item) {
        if (item is Map<String, dynamic> && item.containsKey('path') && item.containsKey('name')) {
          return {'path': item['path'].toString(), 'name': item['name'].toString()};
        } else if (item is String) {
          return {'path': item, 'name': path.basename(item)};
        } else {
          return {'path': '', 'name': 'Invalid attachment'};
        }
      })),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      workspaceId: json['workspaceId'] as String?,
    );
  }
} 