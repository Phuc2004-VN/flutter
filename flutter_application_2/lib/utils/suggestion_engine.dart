import 'package:flutter_application_2/models/schedule.dart';

class SuggestionEngine {
  final List<Schedule> _schedules;
  
  SuggestionEngine(this._schedules);

  List<Schedule> getSuggestions() {
    // TODO: Implement more sophisticated suggestion logic
    // For now, return a simple suggestion based on current time and incomplete tasks
    final now = DateTime.now();
    final incompleteTasks = _schedules.where((schedule) => !schedule.isCompleted).toList();
    
    if (incompleteTasks.isEmpty) {
      return [];
    }

    // Sort tasks by priority and due date
    incompleteTasks.sort((a, b) {
      // First sort by priority
      final priorityOrder = {'Cao': 0, 'Trung bình': 1, 'Thấp': 2};
      final aPriority = a.priority ?? 'Thấp';
      final bPriority = b.priority ?? 'Thấp';
      final priorityComparison = priorityOrder[aPriority]!.compareTo(priorityOrder[bPriority]!);
      if (priorityComparison != 0) return priorityComparison;
      
      // Then sort by due date
      return a.date.compareTo(b.date);
    });

    // Return top 3 suggestions
    return incompleteTasks.take(3).toList();
  }

  // Helper method to get time-based suggestions
  List<Schedule> _getTimeBasedSuggestions(DateTime currentTime) {
    final hour = currentTime.hour;
    List<Schedule> suggestions = [];

    // Morning suggestions (6-11)
    if (hour >= 6 && hour < 11) {
      suggestions = _schedules.where((schedule) {
        return !schedule.isCompleted && 
               schedule.date.isAfter(currentTime) &&
               (schedule.priority ?? '') == 'Cao';
      }).toList();
    }
    // Afternoon suggestions (11-17)
    else if (hour >= 11 && hour < 17) {
      suggestions = _schedules.where((schedule) {
        final priority = schedule.priority ?? '';
        return !schedule.isCompleted && 
               schedule.date.isAfter(currentTime) &&
               (priority == 'Cao' || priority == 'Trung bình');
      }).toList();
    }
    // Evening suggestions (17-22)
    else if (hour >= 17 && hour < 22) {
      suggestions = _schedules.where((schedule) {
        return !schedule.isCompleted && 
               schedule.date.isAfter(currentTime);
      }).toList();
    }

    return suggestions;
  }

  // Hàm tính điểm cho một lịch trình dựa trên deadline và ưu tiên
  int _calculateTaskScore(Schedule schedule) {
    int score = 0;

    // Ưu tiên theo deadline
    if (schedule.deadline != null) {
      final now = DateTime.now();
      final remainingTime = schedule.deadline!.difference(now);

      if (remainingTime.isNegative) {
        // Nhiệm vụ đã trễ
        score += 100; // Điểm rất cao cho nhiệm vụ quá hạn
      } else if (remainingTime.inDays <= 1) {
        // Hết hạn trong vòng 24 giờ
        score += 50;
      } else if (remainingTime.inDays <= 3) {
        // Hết hạn trong vòng 3 ngày
        score += 30;
      } else if (remainingTime.inDays <= 7) {
        // Hết hạn trong vòng 7 ngày
        score += 10;
      }
    }

    // Ưu tiên theo mức độ quan trọng
    switch (schedule.priority) {
      case 'Cao':
        score += 40;
        break;
      case 'Trung bình':
        score += 20;
        break;
      case 'Thấp':
        // Điểm thấp hoặc không cộng điểm
        break;
    }

    // Có thể thêm các yếu tố khác như thời gian tạo, số lần chỉnh sửa, v.v.

    return score;
  }

  // Hàm lấy lịch trình được gợi ý dựa trên danh sách
  Schedule? getSuggestedTask(List<Schedule> schedules) {
    // Chỉ xem xét các nhiệm vụ chưa hoàn thành và có deadline hoặc ưu tiên được đặt
    final eligibleSchedules = schedules.where((s) =>
        !s.isCompleted && (s.deadline != null || s.priority != null));

    if (eligibleSchedules.isEmpty) {
      return null; // Không có lịch trình nào đủ điều kiện để gợi ý
    }

    // Tính điểm cho từng lịch trình và tìm lịch trình có điểm cao nhất
    Schedule? bestTask;
    int maxScore = -1;

    for (final schedule in eligibleSchedules) {
      final currentScore = _calculateTaskScore(schedule);
      if (currentScore > maxScore) {
        maxScore = currentScore;
        bestTask = schedule;
      }
    }

    return bestTask;
  }
} 