import 'package:flutter/material.dart';

class TagManager {
  static const List<String> tags = [
    'Quan trọng',
    'Công việc',
    'Cá nhân',
    'Học tập',
    'Giải trí',
    'Sức khỏe',
    'Gia đình',
    'Bạn bè',
    'Khác'
  ];
  
  static final List<Color> tagColors = [
    Colors.red.shade400,
    Colors.blue.shade800,
    Colors.green.shade400,
    Colors.purple.shade400,
    Colors.orange.shade400,
    Colors.pink.shade400,
    Colors.teal.shade400,
    Colors.indigo.shade400,
    Colors.amber.shade400,
  ];

  static const List<IconData> tagIcons = [
    Icons.priority_high_rounded,
    Icons.work_rounded,
    Icons.person_rounded,
    Icons.school_rounded,
    Icons.sports_esports_rounded,
    Icons.favorite_rounded,
    Icons.family_restroom_rounded,
    Icons.people_rounded,
    Icons.label_rounded,
  ];

  static Color getTagColor(String tag) {
    final index = tags.indexOf(tag);
    if (index >= 0 && index < tagColors.length) {
      return tagColors[index];
    }
    return Colors.grey;
  }

  static IconData getTagIcon(String tag) {
    final index = tags.indexOf(tag);
    if (index >= 0 && index < tagIcons.length) {
      return tagIcons[index];
    }
    return Icons.label_rounded;
  }
} 