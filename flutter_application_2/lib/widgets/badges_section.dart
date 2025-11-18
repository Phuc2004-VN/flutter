import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../models/schedule_model.dart';
import 'package:collection/collection.dart'; // Import for groupBy
import 'package:intl/intl.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  // Define the list of badges
  static const List<Badge> _allBadges = [
    Badge(
      id: 'newbie',
      name: 'Người mới',
      description: 'Tạo nhiệm vụ đầu tiên',
      icon: Icons.star_border,
    ),
    Badge(
      id: 'consistent',
      name: 'Đều đặn',
      description: 'Hoàn thành nhiệm vụ mỗi ngày trong 7 ngày liên tiếp',
      icon: Icons.calendar_today,
    ),
    Badge(
      id: 'on_time',
      name: 'Đúng giờ',
      description: 'Hoàn thành 5 nhiệm vụ đúng deadline',
      icon: Icons.timer,
    ),
     Badge(
      id: 'super_producer',
      name: 'Siêu năng suất',
      description: 'Hoàn thành 3 nhiệm vụ "Ưu tiên cao" trong một ngày',
      icon: Icons.rocket_launch,
    ),
     Badge(
      id: 'night_owl',
      name: 'Kẻ đêm khuya',
      description: 'Tạo nhiệm vụ sau 12h đêm',
      icon: Icons.bedtime,
    ),
  ];

  // Function to check if a badge is earned
  bool _isBadgeEarned(Badge badge, List<Schedule> allSchedules) {
    switch (badge.id) {
      case 'newbie':
        return allSchedules.isNotEmpty;

      case 'consistent':
        if (allSchedules.length < 7) return false;
        // Check for 7 consecutive days with at least one completed task
        final completedSchedules = allSchedules.where((s) => s.isCompleted).toList();
        if (completedSchedules.length < 7) return false;

        // Group completed schedules by date
        final Map<String, List<Schedule>> groupedByDate = groupBy(
          completedSchedules,
          (schedule) => DateFormat('yyyy-MM-dd').format(schedule.date),
        );

        // Check for 7 consecutive dates with completed tasks
        final sortedDates = groupedByDate.keys.toList()..sort();
        if (sortedDates.length < 7) return false;

        for (int i = 0; i <= sortedDates.length - 7; i++) {
          bool consecutive = true;
          for (int j = 0; j < 7; j++) {
            final currentDate = DateTime.parse(sortedDates[i + j]);
            final nextDate = currentDate.add(const Duration(days: 1));
            if (j < 6 && (i + j + 1 >= sortedDates.length || DateTime.parse(sortedDates[i + j + 1]) != nextDate)) {
              consecutive = false;
              break;
            }
          }
          if (consecutive) return true;
        }
        return false;

      case 'on_time':
        // TODO: Implement logic to check if task was completed before its deadline
        // This requires storing completion time and deadline in Schedule model
        // For now, return false
        return false; // Placeholder

      case 'super_producer':
        final highPriorityCompletedToday = allSchedules.where((s) =>
            s.isCompleted &&
            s.priority == 'Cao' &&
            s.date.year == DateTime.now().year &&
            s.date.month == DateTime.now().month &&
            s.date.day == DateTime.now().day
        ).toList();
        return highPriorityCompletedToday.length >= 3;

      case 'night_owl':
         return allSchedules.any((s) => s.date.hour >= 0 && s.date.hour < 5); // Assuming night is between 0:00 and 4:59

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the ScheduleProvider to get all schedules
    final allSchedules = Provider.of<ScheduleProvider>(context).allSchedules;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use card color for consistency
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Huy hiệu cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16.0),
          // Display the list of badges
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allBadges.length,
            itemBuilder: (context, index) {
              final badge = _allBadges[index];
              final isEarned = _isBadgeEarned(badge, allSchedules);
              return Opacity(
                opacity: isEarned ? 1.0 : 0.4,
                child: ListTile(
                  leading: Icon(
                    badge.icon,
                    color: isEarned ? Colors.amber : Colors.grey,
                  ),
                  title: Text(
                    badge.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isEarned ? null : Colors.grey.shade700, // Dim text for unearned
                    ),
                  ),
                  subtitle: Text(
                    badge.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isEarned ? Colors.grey.shade700 : Colors.grey.shade600,
                    ),
                  ),
                  // Optional: Add onTap to show more details about the badge
                  // onTap: () {
                  //   // Show badge details dialog
                  // },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 