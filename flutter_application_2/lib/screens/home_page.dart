import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/workspace.dart';
import 'package:intl/intl.dart';
import 'add_schedule_page.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'setting_screen.dart';
import 'notifications_screen.dart';
import '../models/schedule.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../utils/tag_manager.dart';
import '../widgets/greeting_and_filters_section.dart';
import '../widgets/top_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:open_filex/open_filex.dart';
import '../utils/suggestion_engine.dart';
import '../widgets/suggestion_chatbot.dart';
import 'package:flutter_application_2/auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Tất cả';
  final TextEditingController _quickNoteController = TextEditingController();
  String _loggedInUsername = '';
  String _loggedInUserEmail = '';
  String _loggedInUserAvatar = '';
  late SuggestionEngine _suggestionEngine;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // Provider.of<ScheduleProvider>(context, listen: false).fetchSchedules();
    _suggestionEngine = SuggestionEngine([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _quickNoteController.dispose();
    super.dispose();
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUsername = prefs.getString('logged_in_username') ?? '';
      _loggedInUserEmail = prefs.getString('logged_in_user_email') ?? '';
      _loggedInUserAvatar = prefs.getString('logged_in_user_avatar') ?? '';
    });
  }

  void _addSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSchedulePage(),
      ),
    );
    if (!mounted) return;
    if (result != null && result is Schedule) {
      Provider.of<ScheduleProvider>(context, listen: false).addSchedule(result);
    }
  }

  void _editSchedule(int index) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final schedules = provider.schedules;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSchedulePage(
          initialData: {
            'title': schedules[index].title,
            'date': schedules[index].date.toIso8601String(),
            'time': schedules[index].time,
            'tags': schedules[index].tags.join(', '),
            'isCompleted': schedules[index].isCompleted,
            'priority': schedules[index].priority,
            'deadline': schedules[index].deadline?.toIso8601String(),
            'description': schedules[index].description,
            'attachments': schedules[index].attachments,
          },
        ),
      ),
    );
    if (result != null && result is Schedule) {
      provider.updateSchedule(index, result);
    }
  }

  void _deleteSchedule(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xác nhận xóa lịch trình'),
      content: Text('Bạn có chắc chắn muốn xóa lịch trình này?'),
      actions: [
        TextButton(
          child: const Text('Hủy'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            Provider.of<ScheduleProvider>(context, listen: false).deleteSchedule(index);
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticsScreen(schedules: Provider.of<ScheduleProvider>(context).schedules),
          ),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingScreen()),
        );
      }
    });
  }

  // Hàm để hiển thị hộp thoại thêm workspace
  void onToggleComplete(int index) async {
    Provider.of<ScheduleProvider>(context, listen: false).toggleCompletionStatus(index);
}

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    String weekday = DateFormat('EEEE', 'vi_VN').format(now);
    String day = DateFormat('d', 'vi_VN').format(now);
    String month = DateFormat('M', 'vi_VN').format(now);
    String year = DateFormat('y', 'vi_VN').format(now);
    return '$weekday, $day tháng $month năm $year';
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Buổi sáng';
    if (hour < 13) return 'Buổi trưa';
    if (hour < 18) return 'Buổi chiều';
    return 'Buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final schedules = Provider.of<ScheduleProvider>(context).schedules;
    final completedTasksCount = schedules.where((schedule) => schedule.isCompleted).length;

    _suggestionEngine = SuggestionEngine(schedules);
    final suggestions = _suggestionEngine.getSuggestions();

    List<Schedule> filteredSchedules = [];
    switch (_selectedFilter) {
      case 'Tất cả':
        filteredSchedules = schedules;
        break;
      case 'Hôm nay':
        filteredSchedules = schedules.where((s) => s.date.year == DateTime.now().year && s.date.month == DateTime.now().month && s.date.day == DateTime.now().day).toList();
        break;
      case 'Hoàn thành':
        filteredSchedules = schedules.where((s) => s.isCompleted).toList();
        break;
      case 'Chưa hoàn thành':
        filteredSchedules = schedules.where((s) => !s.isCompleted).toList();
        break;
      default:
        filteredSchedules = schedules;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New Top Navigation Bar Container
              TopNavBar(
                isDark: isDark,
                onAddWorkspacePressed: () => _showAddWorkspaceDialog(context),
                onLoginPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                loggedInUsername: _loggedInUsername,
                loggedInUserEmail: _loggedInUserEmail,
                loggedInUserAvatar: _loggedInUserAvatar,
                onLogout: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.grey.shade100,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Trang chủ', isDark),
                    _buildNavItem(1, Icons.calendar_month_rounded, '  Lịch  ', isDark),
                    _buildNavItem(2, Icons.analytics_rounded, 'Thống kê', isDark),
                    _buildNavItem(3, Icons.notifications_rounded, 'Thông báo', isDark),
                    _buildNavItem(4, Icons.settings_rounded, 'Cài đặt', isDark),
                  ],
                ),
              ),
              // Use the extracted GreetingAndFiltersSection widget
              GreetingAndFiltersSection(
                isDark: isDark,
                greeting: _getGreeting(),
                currentDate: _getCurrentDate(),
                selectedFilter: _selectedFilter,
                onFilterChanged: (newValue) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                },
                 onFocusModePressed: () {
                   Navigator.pushNamed(context, '/focus');
                 },
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tổng quan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildSummaryCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Hôm nay',
                      value: '${schedules.length} nhiệm vụ',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 20),
                    _buildSummaryCard(
                      icon: Icons.task_alt_rounded,
                      title: 'Hoàn thành',
                      value: '$completedTasksCount nhiệm vụ',
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 32),
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriorityColumn(context, 'Cao', filteredSchedules.where((s) => s.priority == 'Cao').toList(), isDark, schedules),
                      const SizedBox(width: 20),
                      _buildPriorityColumn(context, 'Trung bình', filteredSchedules.where((s) => s.priority == 'Trung bình').toList(), isDark, schedules),
                      const SizedBox(width: 20),
                      _buildPriorityColumn(context, 'Thấp', filteredSchedules.where((s) => s.priority == 'Thấp').toList(), isDark, schedules),
                      const SizedBox(width: 20),
                      Container(
                        width: 280,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (isDark ? Colors.blueGrey.shade900 : Colors.blue.shade100).withOpacity(0.6),
                              (isDark ? Colors.blueGrey.shade700 : Colors.blue.shade50).withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? Colors.blueGrey.shade700.withOpacity(0.5) : Colors.blue.shade100.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: suggestions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 40, color: isDark ? Colors.white70 : Colors.grey.shade600),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Không có gợi ý công việc',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Hoàn thành các công việc hiện tại để nhận gợi ý mới.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, size: 24, color: isDark ? Colors.white70 : Colors.grey.shade600),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Gợi ý công việc',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: suggestions.length,
                                      itemBuilder: (context, index) {
                                        final suggestion = suggestions[index];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          color: isDark ? Colors.blueGrey.shade800.withOpacity(0.5) : Colors.white.withOpacity(0.8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  suggestion.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark ? Colors.white : Colors.grey.shade800,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                     Icon(
                                                       _getPriorityIcon(suggestion.priority),
                                                       size: 14,
                                                       color: _getPriorityColor(suggestion.priority, isDark),
                                                    ),
                                                    const SizedBox(width: 4),
                                                   Text(
                                                      DateFormat('HH:mm dd/MM').format(suggestion.date),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                                                      ),
                                                    ),
                                                 ],
                                                ),
                                                const SizedBox(height: 12),
                                                ElevatedButton.icon(
                                                  icon: const Icon(Icons.question_answer, size: 18), // Reduced icon size
                                                  label: const Text('Vì sao gợi ý việc này?', style: TextStyle(fontSize: 12)), // Reduced text size
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return SuggestionChatBot(suggestedTask: suggestion);
                                                      },
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjusted padding
                                                    minimumSize: Size.zero, // Allow button to be smaller than default
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer Section
              Container(
                color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade900, // Dark background for footer
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column 1: Company Info
                        const Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HỆ THỐNG SẮP XẾP LỊCH TRÌNH',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Ứng dụng giúp bạn quản lý lịch trình và công việc hiệu quả.', // Placeholder description
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Column 2: Liên hệ / Hỗ trợ
                        Expanded(
                           flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const Text(
                                'Liên hệ / Hỗ trợ',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Email: support@yourdomain.com',
                                style: TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                               const SizedBox(height: 4),
                               const Text(
                                'Hotline: 0123 456 789',
                                style: TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement Hướng dẫn sử dụng link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('[Hướng dẫn sử dụng]', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Trung tâm trợ giúp link
                                },
                                 style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('[Trung tâm trợ giúp]', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Gửi phản hồi link
                                },
                                 style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('[Gửi phản hồi]', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                         const SizedBox(width: 24),

                        // Column 3: Liên kết nhanh
                         Expanded(
                           flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liên kết nhanh',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.white70),
                              ),
                               const SizedBox(height: 8),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Trang chủ link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Trang chủ', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Lịch link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Lịch', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Thống kê link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Thống kê', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Cài đặt link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Cài đặt', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                         const SizedBox(width: 24),

                        // Column 4: Policies / Version
                         Expanded(
                           flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thông báo pháp lý / Chính sách',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                               const SizedBox(height: 8),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Chính sách bảo mật link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Chính sách bảo mật', style: TextStyle(fontSize: 12)),
                              ),
                               TextButton(
                                onPressed: () {
                                  // TODO: Implement Điều khoản sử dụng link
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                                child: const Text('Điều khoản sử dụng', style: TextStyle(fontSize: 12)),
                              ),
                               const SizedBox(height: 16), // Space before version
                               Text(
                                'Phiên bản hệ thống:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                               const SizedBox(height: 8),
                                Text(
                                'Cập nhật lần cuối: 01/06/2025', // You can make this dynamic if needed
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28), // Space before copyright
                    // Bottom Copyright Section
                    Container(
                       alignment: Alignment.center,
                       padding: const EdgeInsets.symmetric(vertical: 16.0),
                       decoration: BoxDecoration(
                         border: Border(top: BorderSide(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade700, width: 1.0)),
                       ), // Add a top border
                       child: Text(
                        '© 2025 Hệ thống sắp xếp lịch trình. Đã đăng ký bản quyền.',
                        textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSchedule,
        backgroundColor: Colors.blue.shade600,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm lịch trình',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        tooltip: 'Thêm lịch trình mới',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _selectedIndex == index;
    Color itemColor = isSelected ? Colors.blue.shade600 : (isDark ? Colors.white70 : Colors.grey.shade400);
    Color backgroundColor = isSelected ? (isDark ? Colors.blue.shade900 : Colors.blue.shade50) : Colors.transparent;
    Color hoverColor = isDark ? Colors.blue.shade800.withOpacity(0.3) : Colors.blue.shade50.withOpacity(0.9);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: () => _onItemTapped(index),
            borderRadius: BorderRadius.circular(12),
            hoverColor: hoverColor,
            splashColor: isDark ? Colors.blue.shade900 : Colors.grey.shade200,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon, 
                    color: itemColor,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () { /* Optional: Handle tap on summary card */ },
        onHover: (isHovering) {
          // You might need to manage a state variable to change the card's appearance on hover
          // For simplicity, InkWell's splash/highlight is often sufficient for basic feedback
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900.withOpacity(0.8) : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: isDark ? Colors.blueGrey.shade700.withOpacity(0.5) : Colors.grey.shade300.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityColumn(BuildContext context, String title, List<Schedule> prioritySchedules, bool isDark, List<Schedule> allSchedules) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? Colors.blueGrey.shade900 : Colors.blue.shade100).withOpacity(0.6),
            (isDark ? Colors.blueGrey.shade700 : Colors.blue.shade50).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.blueGrey.shade700.withOpacity(0.5) : Colors.blue.shade100.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: prioritySchedules.isEmpty
                ? Center(
                    child: Text(
                      'Không có lịch trình ${title.toLowerCase()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: prioritySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = prioritySchedules[index];
                      return InkWell(
                        onTap: () { /* Optional: Handle tap on card */ },
                        onHover: (isHovering) {
                          // You might need to manage a state variable to change the card's appearance on hover
                          // For simplicity, InkWell's splash/highlight is often sufficient for basic feedback
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Hiển thị mô tả nếu có
                                if (schedule.description != null && schedule.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      schedule.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      ),
                                      maxLines: 3, // Giới hạn số dòng hiển thị mô tả
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thời gian tạo:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(schedule.date),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      TimeUtils.formatTimeOfDay(schedule.time),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                    ),
                                  ],
                                ),
                                // Hiển thị thời hạn hoàn thành nếu có
                                if (schedule.deadline != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer_rounded, size: 14, color: Colors.orange.shade600), // Icon cho thời hạn
                                        const SizedBox(width: 6),
                                        Text(
                                          'Hết hạn: ${DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(schedule.deadline!)}',
                                          style: TextStyle(
                                            color: Colors.orange.shade600,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (schedule.tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: schedule.tags.map((tag) {
                                        final color = TagManager.getTagColor(tag);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1), // Adjusted opacity
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: color.withOpacity(0.3)), // Adjusted opacity
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                // Hiển thị danh sách file đính kèm nếu có
                                if (schedule.attachments.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Đính kèm:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white60 : Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: schedule.attachments.map((attachment) {
                                            // Sử dụng tên file từ map thay vì đường dẫn
                                            final fileName = attachment['name'] ?? 'File';
                                            final filePath = attachment['path'] ?? ''; // Lấy đường dẫn để có thể mở file nếu cần
                                            return InkWell(
                                              onTap: () => _openFile(filePath), // Open the file on tap
                                              child: Container(
                                                // Giới hạn chiều rộng của mỗi item file đính kèm
                                                constraints: const BoxConstraints(maxWidth: 200), // Điều chỉnh chiều rộng tối đa tùy ý
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100, // Adjusted color
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                     Icon(
                                                      _getFileIcon(fileName), // Sử dụng hàm getFileIcon
                                                      size: 12,
                                                      color: _getFileColor(fileName, isDark), // Áp dụng màu sắc theo loại file
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        fileName,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: _getFileColor(fileName, isDark), // Áp dụng màu sắc theo loại file
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    // Có thể thêm icon để mở file ở đây nếu cần
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        schedule.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                        color: schedule.isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      onPressed: schedule.isCompleted
                                          ? null // Không cho phép chỉnh lại nếu đã hoàn thành
                                          : () => onToggleComplete(index),
                                      tooltip: schedule.isCompleted ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 18), // Adjusted color
                                      onPressed: () => _editSchedule(allSchedules.indexOf(schedule)),
                                      tooltip: 'Chỉnh sửa lịch trình',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18), // Adjusted color
                                      onPressed: () => _deleteSchedule(allSchedules.indexOf(schedule)),
                                      tooltip: 'Xóa lịch trình',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.mp3':
      case '.wav':
        return Icons.audio_file;
      case '.mp4':
      case '.avi':
      case '.mov':
        return Icons.video_file;
      case '.zip':
      case '.rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Hàm trả về màu sắc dựa trên loại file
  Color _getFileColor(String fileName, bool isDark) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case '.doc':
      case '.docx':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case '.xls':
      case '.xlsx':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case '.ppt':
      case '.pptx':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case '.mp3':
      case '.wav':
        return isDark ? Colors.teal.shade300 : Colors.teal.shade700;
      case '.mp4':
      case '.avi':
      case '.mov':
        return isDark ? Colors.indigo.shade300 : Colors.indigo.shade700;
      case '.zip':
      case '.rar':
        return isDark ? Colors.brown.shade300 : Colors.brown.shade700;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade700; // Màu mặc định
    }
  }

  // Method to show add workspace dialog - Ensure this is inside _HomePageState
  void _showAddWorkspaceDialog(BuildContext context) {
    final TextEditingController workspaceNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tạo Workspace mới'),
          content: TextField(
            controller: workspaceNameController,
            decoration: const InputDecoration(hintText: 'Nhập tên Workspace'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu'),
              onPressed: () {
                final workspaceName = workspaceNameController.text.trim();
                if (workspaceName.isNotEmpty) {
                  // Add the new workspace
                  Provider.of<ScheduleProvider>(context, listen: false).addWorkspace(
                    Workspace(id: DateTime.now().toString(), name: workspaceName), // Simple unique ID for now
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm mở file
  void _openFile(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở file: $e')),
      );
    }
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority ?? '') {
      case 'Cao':
        return Icons.arrow_upward;
      case 'Trung bình':
        return Icons.arrow_forward;
      case 'Thấp':
        return Icons.arrow_downward;
      default:
        return Icons.flag;
    }
  }

  Color _getPriorityColor(String? priority, bool isDark) {
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

  // Helper function to generate suggestion reason
  String _getSuggestionReason(Schedule suggestion, bool isDark) {
    final now = DateTime.now();
    String reason = '';

    // Check for overdue tasks first
    if (suggestion.deadline != null && suggestion.deadline!.isBefore(now)) {
      reason = 'Đã quá hạn';
    } else if (suggestion.priority == 'Cao') {
      reason = 'Ưu tiên cao';
    } else if (suggestion.deadline != null) {
      final remainingTime = suggestion.deadline!.difference(now);
      if (remainingTime.inDays <= 1) {
        reason = 'Hết hạn hôm nay/ngày mai';
      } else if (remainingTime.inDays <= 3) {
        reason = 'Hết hạn trong 3 ngày tới';
      } else {
         reason = 'Ưu tiên ${suggestion.priority ?? 'Thấp'}';
      }
    } else if (suggestion.priority != null) {
       reason = 'Ưu tiên ${suggestion.priority}';
    } else {
      reason = 'Nhiệm vụ chưa hoàn thành'; // Default reason
    }
    
    return reason;
  }
}