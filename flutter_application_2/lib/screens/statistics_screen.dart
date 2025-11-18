import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/statistics_charts.dart';
import '../widgets/statistics_summary_cards.dart';
import '../utils/statistics_utils.dart';
import '../utils/tag_manager.dart';
import '../models/schedule.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Schedule> schedules;

  const StatisticsScreen({Key? key, required this.schedules}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Hôm nay';
  String _selectedFilter = 'Tất cả';
  String _appliedPeriod = 'Hôm nay';
  String _appliedFilter = 'Tất cả';
  final List<String> _periods = ['Hôm nay', 'Tuần này', 'Tháng này', 'Năm nay'];
  final List<String> _filters = ['Tất cả', 'Quan trọng', 'Công việc', 'Cá nhân', 'Học tập', 'Giải trí', 'Sức khỏe', 'Gia đình', 'Bạn bè', 'Khác'];

  // Lấy danh sách tag động từ TagManager
  List<String> get tags => TagManager.tags;

  // Tính toán số liệu động
  int get _totalTasks => widget.schedules.length;
  int get _completedTasks => widget.schedules.where((s) => s.isCompleted).length;
  int get _upcomingTasks => _totalTasks - _completedTasks;

  // Tính toán hiệu suất hoàn thành
  double get _completionRate => StatisticsUtils.calculateCompletionRate(_totalTasks, _completedTasks);
  double get _averageCompletionTime => StatisticsUtils.calculateAverageCompletionTime(widget.schedules);

  // Lọc danh sách nhiệm vụ theo thời gian và tag
  List<Schedule> get filteredSchedules {
    List<Schedule> filtered = widget.schedules;
    // Lọc theo thời gian
    switch (_selectedPeriod) {
      case 'Hôm nay':
        final today = DateTime.now();
        filtered = filtered.where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day).toList();
        break;
      case 'Tuần này':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        filtered = filtered.where((s) => s.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && s.date.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();
        break;
      case 'Tháng này':
        final now = DateTime.now();
        filtered = filtered.where((s) => s.date.year == now.year && s.date.month == now.month).toList();
        break;
      case 'Năm nay':
        final now = DateTime.now();
        filtered = filtered.where((s) => s.date.year == now.year).toList();
        break;
    }
    // Lọc theo tag
    if (_selectedFilter != 'Tất cả') {
      filtered = filtered.where((s) => s.tags.contains(_selectedFilter)).toList();
    }
    return filtered;
  }

  List<Schedule> get _appliedFilteredSchedules {
    List<Schedule> filtered = widget.schedules;
    // Lọc theo thời gian
    switch (_appliedPeriod) {
      case 'Hôm nay':
        final today = DateTime.now();
        filtered = filtered.where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day).toList();
        break;
      case 'Tuần này':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        filtered = filtered.where((s) => s.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && s.date.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();
        break;
      case 'Tháng này':
        final now = DateTime.now();
        filtered = filtered.where((s) => s.date.year == now.year && s.date.month == now.month).toList();
        break;
      case 'Năm nay':
        final now = DateTime.now();
        filtered = filtered.where((s) => s.date.year == now.year).toList();
        break;
    }
    // Lọc theo tag
    if (_appliedFilter != 'Tất cả') {
      filtered = filtered.where((s) => s.tags.contains(_appliedFilter)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey.shade900, Colors.grey.shade800, Colors.black]
                : [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildFilterDropdown(
                      value: _selectedPeriod,
                      items: _periods,
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                      },
                      label: 'Thời gian',
                      isDark: isDark,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildFilterDropdown(
                      value: _selectedFilter,
                      items: _filters,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                      label: 'Lọc theo',
                      isDark: isDark,
                    )),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.blue.shade700;
                            }
                            return Colors.blue.shade500;
                          }),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                        onPressed: () {
                          setState(() {
                            _appliedPeriod = _selectedPeriod;
                            _appliedFilter = _selectedFilter;
                          });
                        },
                        child: const Text('Lọc', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                StatisticsSummaryCards(
                  totalTasks: _totalTasks,
                  completedTasks: _completedTasks,
                  upcomingTasks: _upcomingTasks,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        StatisticsCharts(
                          schedules: _appliedFilteredSchedules,
                          selectedPeriod: _appliedPeriod,
                          selectedFilter: _appliedFilter,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        _buildPerformanceMetrics(isDark),
                        const SizedBox(height: 24),
                        _buildTaskTypeAnalysis(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'Thống kê',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hiệu suất hoàn thành',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tỷ lệ hoàn thành đúng hạn',
                  '${_completionRate.toStringAsFixed(1)}%',
                  Icons.timer,
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Thời gian trung bình',
                  '${_averageCompletionTime.toStringAsFixed(1)} giờ',
                  Icons.access_time,
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeAnalysis(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích chi tiết',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriorityAnalysis(isDark),
          const SizedBox(height: 24),
          _buildTaskDistribution(isDark),
        ],
      ),
    );
  }

  Widget _buildPriorityAnalysis(bool isDark) {
    final tagCounts = <String, int>{};
    for (final tag in TagManager.tags) {
      tagCounts[tag] = _appliedFilteredSchedules.where((s) => s.tags.contains(tag)).length;
    }
    final maxCount = tagCounts.values.isNotEmpty ? tagCounts.values.reduce((a, b) => a > b ? a : b) : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số lượng nhiệm vụ theo từng tag',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: TagManager.tags.length * 40.0 + 20,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: TagManager.tags.length,
              itemBuilder: (context, i) {
                final tag = TagManager.tags[i];
                final count = tagCounts[tag]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(TagManager.tagIcons[i], color: TagManager.tagColors[i], size: 22),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 110,
                        child: Text(tag, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: TagManager.tagColors[i].withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: 22,
                              width: count == 0 || maxCount == 0 ? 0 : (count / maxCount) * MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                color: TagManager.tagColors[i],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: count > 0
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDistribution(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân bố nhiệm vụ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _appliedFilteredSchedules.isEmpty
            ? Container(
                height: 320,
                alignment: Alignment.center,
                child: Text(
                  'Không có dữ liệu để thống kê',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 16),
                ),
              )
            : SizedBox(
                height: 350,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _pieChartData.map((section) {
                      return PieChartSectionData(
                        color: section.color,
                        value: section.value,
                        title: section.title,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }

  List<PieChartSectionData> get _pieChartData {
    final tagCounts = <String, int>{};
    for (final schedule in _appliedFilteredSchedules) {
      for (final tag in schedule.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    return tagCounts.entries.map((entry) {
      final color = TagManager.getTagColor(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
} 