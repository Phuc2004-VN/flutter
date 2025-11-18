import 'package:flutter/material.dart';

class TimeUtils {
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static TimeOfDay parseTimeString(String timeString) {
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    final period = parts[1].toUpperCase();
    
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }
} 