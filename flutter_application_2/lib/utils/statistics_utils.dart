import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'tag_manager.dart';
import '../models/schedule.dart';

class StatisticsUtils {
  static Color getBarColor({
    required List<Schedule> schedules,
    required String selectedFilter,
    DateTime? day,
    int? month,
    int? year,
  }) {
    if (selectedFilter != 'Tất cả') {
      return TagManager.getTagColor(selectedFilter);
    }

    List<Schedule> filteredTasks;
    if (day != null) {
      filteredTasks = schedules.where((s) =>
        s.date.year == day.year && s.date.month == day.month && s.date.day == day.day
      ).toList();
    } else if (month != null && year != null) {
      filteredTasks = schedules.where((s) =>
        s.date.year == year && s.date.month == month
      ).toList();
    } else {
      return Colors.blue.shade200;
    }

    if (filteredTasks.isEmpty) return Colors.blue.shade200;

    final allTags = filteredTasks.expand((s) => s.tags).toList();
    final uniqueTags = allTags.toSet();
    if (allTags.length == uniqueTags.length) {
      return Colors.blue.shade200;
    }

    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }

    String? mostFrequentTag;
    int maxCount = 0;
    tagCounts.forEach((tag, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentTag = tag;
      }
    });

    if (mostFrequentTag != null) {
      return TagManager.getTagColor(mostFrequentTag!);
    }
    return Colors.blue.shade200;
  }

  static Color getLineColor(List<Schedule> completedToday, String selectedFilter) {
    if (selectedFilter != 'Tất cả') {
      return TagManager.getTagColor(selectedFilter);
    }

    final allTags = completedToday.expand((s) => s.tags).toList();
    final uniqueTags = allTags.toSet();
    if (allTags.length == uniqueTags.length) {
      return Colors.blue.shade200;
    }

    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }

    String? mostFrequentTag;
    int maxCount = 0;
    tagCounts.forEach((tag, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentTag = tag;
      }
    });

    if (mostFrequentTag != null) {
      return TagManager.getTagColor(mostFrequentTag!);
    }
    return Colors.blue.shade200;
  }

  static String getTaskTooltip(List<Schedule> completedToday, FlSpot spot) {
    final matched = completedToday.where((s) =>
      (s.time.hour + s.time.minute / 60) == spot.x &&
      s.tags.length.toDouble() == spot.y
    ).toList();
    if (matched.isEmpty) return '';
    final s = matched.first;
    return '${s.title}\n${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}\nTags: ${s.tags.join(', ')}';
  }

  static double calculateCompletionRate(int totalTasks, int completedTasks) {
    return totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  }

  static double calculateAverageCompletionTime(List<Schedule> schedules) {
    final completedTasks = schedules.where((s) => s.isCompleted).toList();
    if (completedTasks.isEmpty) return 0;
    // TODO: Implement actual completion time calculation
    return 2.5; // Placeholder value
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
