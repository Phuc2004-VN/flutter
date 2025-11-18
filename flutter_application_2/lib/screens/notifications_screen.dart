import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_notification.dart';
import '../models/schedule_model.dart';
import '../providers/setting_provider.dart';
import '../services/notification_service.dart';

Color getPriorityColor(String? priority, bool isDark) {
  switch (priority ?? '') {
    case 'Cao':
      return isDark ? Colors.red.shade300 : Colors.red.shade700;
    case 'Trung bình':
      return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    case 'Thấp':
      return isDark ? Colors.green.shade300 : Colors.green.shade700;
    default:
      return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
  }
}

IconData getPriorityIcon(String? priority) {
  switch (priority ?? '') {
    case 'Cao':
      return Icons.priority_high;
    case 'Trung bình':
      return Icons.trending_up;
    case 'Thấp':
      return Icons.trending_down;
    default:
      return Icons.flag;
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;

  bool _isLoading = true;
  String _filter = 'Tất cả'; // Tất cả, Chưa đọc, Đã đọc
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final schedules = context.read<ScheduleProvider>().schedules;
    final notificationSettings = context.read<NotificationSettingsProvider>();

    if (notificationSettings.notificationEnabled) {
      await _notificationService.syncFromSchedules(schedules, notificationSettings);
    }

    final fetched = await _notificationService.fetchNotifications();
    setState(() {
      _notifications = fetched;
      _isLoading = false;
    });
  }

  Future<void> _markRead(AppNotification notification, bool value) async {
    await _notificationService.markAsRead(notification.id, value);
    await _loadNotifications();
  }

  Future<void> _delete(AppNotification notification) async {
    await _notificationService.deleteNotification(notification.id);
    await _loadNotifications();
  }

  List<AppNotification> _filteredNotifications() {
    if (_filter == 'Chưa đọc') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    if (_filter == 'Đã đọc') {
      return _notifications.where((n) => n.isRead).toList();
    }
    return _notifications;
  }

  Map<String, List<AppNotification>> _groupByPriority(List<AppNotification> notifications) {
    final Map<String, List<AppNotification>> grouped = {
      'Cao': [],
      'Trung bình': [],
      'Thấp': [],
      'Khác': [],
    };
    for (final n in notifications) {
      final key = grouped.containsKey(n.priority) ? n.priority! : 'Khác';
      grouped[key]!.add(n);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationSettings = Provider.of<NotificationSettingsProvider>(context);
    final grouped = _groupByPriority(_filteredNotifications());

    List<Widget> buildGroupedNotifications() {
      final List<Widget> widgets = [];
      grouped.forEach((priority, entries) {
        if (entries.isEmpty) return;

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(getPriorityIcon(priority), color: getPriorityColor(priority, isDark)),
              const SizedBox(width: 8),
              Text(
                'Ưu tiên $priority',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: getPriorityColor(priority, isDark),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: getPriorityColor(priority, isDark).withOpacity(0.3),
                  indent: 12,
                ),
              ),
            ],
          ),
        ));

        widgets.addAll(entries.map((notification) {
          return Card(
            color: isDark
                ? (notification.isRead ? Colors.blueGrey.shade800 : Colors.red.shade900.withOpacity(0.6))
                : (notification.isRead ? Colors.blue.shade50 : Colors.red.shade50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: Icon(
                notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: notification.isRead ? Colors.grey : Colors.orange,
                size: 32,
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blueGrey.shade900,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      notification.isRead ? Icons.undo : Icons.check,
                      color: notification.isRead ? Colors.orangeAccent : Colors.green,
                    ),
                    tooltip: notification.isRead ? 'Đánh dấu chưa đọc' : 'Đánh dấu đã đọc',
                    onPressed: () => _markRead(notification, !notification.isRead),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Xóa thông báo',
                    onPressed: () => _delete(notification),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời điểm: ${DateFormat('HH:mm dd/MM/yyyy').format(notification.createdAt)}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  if (notification.content != null)
                    Text(
                      notification.content!,
                      style: TextStyle(
                        color: notification.isRead
                            ? (isDark ? Colors.white54 : Colors.grey.shade600)
                            : (notificationSettings.reminderBeforeDeadlineEnabled
                                ? Colors.blue
                                : Colors.red[300]),
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        }));
      });
      return widgets;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại trang chủ',
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white),
            color: isDark ? Colors.grey.shade900 : Colors.white,
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Tất cả', child: Text('Tất cả')),
              PopupMenuItem(value: 'Chưa đọc', child: Text('Chưa đọc')),
              PopupMenuItem(value: 'Đã đọc', child: Text('Đã đọc')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: buildGroupedNotifications().isEmpty
                    ? Center(
                        child: Text(
                          notificationSettings.notificationEnabled
                              ? 'Không có thông báo nào'
                              : 'Thông báo đã tắt trong cài đặt.',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildGroupedNotifications(),
                      ),
              ),
            ),
    );
  }
}