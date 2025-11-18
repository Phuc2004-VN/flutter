import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  // Lấy userId từ SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('logged_in_user_id');
  }

  // Lấy danh sách lịch trình từ database
  Future<void> fetchSchedules() async {
    final userId = await _getUserId();
    if (userId == null) return;
    final data = await DatabaseService.instance.getSchedules(userId);
    _schedules = data.map((json) => Schedule.fromJson(json)).toList();
    notifyListeners();
  }

  // Thêm lịch trình
  Future<void> addSchedule(Schedule schedule) async {
    final userId = await _getUserId();
    if (userId == null) return;
    final success = await DatabaseService.instance.saveSchedule(userId, schedule.toJson());
    if (success) {
      await fetchSchedules();
    }
  }

  // Sửa lịch trình
  Future<void> updateSchedule(int index, Schedule schedule) async {
    if (index < 0 || index >= _schedules.length) return;
    final scheduleId = _schedules[index].id;
    if (scheduleId == null) return;
    final success = await DatabaseService.instance.updateSchedule(int.parse(scheduleId.toString()), schedule.toJson()); //ép kiểu id về int
    if (success) {
      await fetchSchedules();
    }
  }

  // Xóa lịch trình
  Future<void> deleteSchedule(int index) async {
    if (index < 0 || index >= _schedules.length) return;
    final scheduleId = _schedules[index].id;
    if (scheduleId == null) return;
    final success = await DatabaseService.instance.deleteSchedule(int.parse(scheduleId));
    if (success) {
      await fetchSchedules();
    }
  }

  // Đánh dấu hoàn thành
  Future<void> toggleCompletionStatus(int index) async {
    if (index < 0 || index >= _schedules.length) return;
    final schedule = _schedules[index];
    final updated = schedule.copyWith(isCompleted: !schedule.isCompleted);
    await updateSchedule(index, updated);
  }
}