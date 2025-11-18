import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  late final SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    _initializeVietnameseHolidays();
  }

  void _loadEvents() async {
    _prefs = await SharedPreferences.getInstance();
    String? eventsString = _prefs.getString('events');
    if (eventsString != null) {
      Map<String, dynamic> eventsJson = json.decode(eventsString);
      _events = eventsJson.map((key, value) {
        DateTime date = DateTime.parse(key);
        List<Event> events = (value as List).map((e) => Event(e['title'])).toList();
        return MapEntry(date, events);
      });
      setState(() {});
    }
  }

  void _initializeVietnameseHolidays() {
    _events[DateTime(2024, 1, 1)] = [Event('Tết Dương lịch', isHoliday: true)];
    _events[DateTime(2024, 2, 10)] = [Event('Tết Nguyên đán', isHoliday: true)];
    _events[DateTime(2024, 4, 30)] = [Event('Ngày Giải phóng miền Nam', isHoliday: true)];
    _events[DateTime(2024, 5, 1)] = [Event('Ngày Quốc tế Lao động', isHoliday: true)];
    _events[DateTime(2024, 9, 2)] = [Event('Ngày Quốc khánh', isHoliday: true)];
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade400,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Calendar
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TableCalendar(
                        locale: 'vi_VN',
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.utc(2025, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue.shade700),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue.shade700),
                          titleTextStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        availableCalendarFormats: const { CalendarFormat.month: 'Month' },
                        calendarStyle: CalendarStyle(
                          markerDecoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            shape: BoxShape.circle,
                          ),
                          holidayTextStyle: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 10,
                          ),
                          defaultTextStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.red.shade300,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Calendar List (made scrollable to prevent overflow)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text(
                              'Lịch của tôi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildCalendarItem(Icons.person, 'Lịch cá nhân'),
                            _buildCalendarItem(Icons.cake, 'Sinh nhật'),
                            _buildCalendarItem(Icons.notifications, 'Nhắc nhở'),
                            _buildCalendarItem(Icons.task, 'Công việc'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Calendar Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.black54),
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                                _selectedDay = _focusedDay;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.black54),
                            onPressed: () {
                              setState(() {
                                _focusedDay = _focusedDay.add(const Duration(days: 7));
                                _selectedDay = _focusedDay;
                              });
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime.now();
                                _selectedDay = DateTime.now();
                              });
                            },
                            child: const Text(
                              'Hôm nay',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDay ?? DateTime.now(),
                                firstDate: DateTime.utc(2024, 1, 1),
                                lastDate: DateTime.utc(2025, 12, 31),
                                locale: const Locale('vi', 'VN'),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: Colors.blue.shade700,
                                      colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
                                      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null && picked != _selectedDay) {
                                setState(() {
                                  _selectedDay = picked;
                                  _focusedDay = picked;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy', 'vi_VN').format(_focusedDay),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tuần',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Section Title for Schedules
                    Text(
                      'Lịch trình vào ngày ${DateFormat('dd/MM/yyyy', 'vi_VN').format(_selectedDay!)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Display Schedules for Selected Day
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final scheduleProvider = context.watch<ScheduleProvider>();
                          // Filter schedules for the selected day
                          final selectedDaySchedules = scheduleProvider.schedules.where((schedule) {
                            return isSameDay(schedule.date, _selectedDay);
                          }).toList();

                          if (selectedDaySchedules.isEmpty) {
                            return Center(
                              child: Text(
                                'Không có lịch trình nào vào ngày này.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: selectedDaySchedules.length,
                              itemBuilder: (context, index) {
                                final schedule = selectedDaySchedules[index];
                                // Improved styling for schedule items
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      schedule.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 16, color: Colors.blue.shade400),
                                            const SizedBox(width: 8),
                                            Text(
                                              TimeUtils.formatTimeOfDay(schedule.time),
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                        // Add more details like tags, priority, deadline if needed
                                        if (schedule.tags.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: schedule.tags.map((tag) {
                                                // You would need a TagManager or similar logic here to get color/icon
                                                // For now, a simple representation:
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100, // Placeholder color
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(tag, style: TextStyle(fontSize: 12, color: Colors.blue.shade800)),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // You might want to add edit/delete icons here as well
                                  ),
                                );
                              },
                            );
                          }
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
    );
  }

  Widget _buildCalendarItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String newEventTitle = '';
}

class Event {
  final String title;
  final bool isHoliday;
  
  Event(this.title, {this.isHoliday = false});
}

class TimeUtils {
  static String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); // e.g. 5:08 PM
    return format.format(dt);
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
} 