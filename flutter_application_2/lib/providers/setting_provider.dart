import 'package:flutter/material.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool notificationEnabled;
  bool reminderBeforeDeadlineEnabled;
  int reminderMinutesBefore;

  NotificationSettingsProvider({
    this.notificationEnabled = true,
    this.reminderBeforeDeadlineEnabled = false,
    this.reminderMinutesBefore = 10,
  });

  void setNotificationEnabled(bool value) {
    notificationEnabled = value;
    notifyListeners();
  }

  void setReminderBeforeDeadlineEnabled(bool value) {
    reminderBeforeDeadlineEnabled = value;
    notifyListeners();
  }

  void setReminderMinutesBefore(int value) {
    reminderMinutesBefore = value;
    notifyListeners();
  }
}