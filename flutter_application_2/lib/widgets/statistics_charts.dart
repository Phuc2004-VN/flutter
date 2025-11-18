import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/statistics_utils.dart';
import '../models/schedule.dart';

class StatisticsCharts extends StatelessWidget {
  final List<Schedule> schedules;
  final String selectedPeriod;
  final String selectedFilter;
  final bool isDark;

  const StatisticsCharts({
    Key? key,
    required this.schedules,
    required this.selectedPeriod,
    required this.selectedFilter,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedPeriod == 'Tuần này') {
      return _buildWeekBarChart(context);
    } else if (selectedPeriod == 'Tháng này') {
      return _buildMonthBarChart(context);
    } else if (selectedPeriod == 'Năm nay') {
      return _buildYearBarChart(context);
    } else {
      return _buildSimpleLineChart(context);
    }
  }

  Widget _buildWeekBarChart(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final counts = days.map((day) =>
      schedules.where((s) =>
        s.date.year == day.year && s.date.month == day.month && s.date.day == day.day
      ).length.toDouble()
    ).toList();

    return _buildCustomBarChart(
      context: context,
      labels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
      values: counts,
      tooltipBuilder: (index) {
        final day = days[index];
        final tasks = schedules.where((s) =>
          s.date.year == day.year && s.date.month == day.month && s.date.day == day.day
        ).toList();
        if (tasks.isEmpty) return 'Không có nhiệm vụ';
        return tasks.map((s) => '${s.title} (${s.time.format(context)})').join('\n');
      },
      getBarColor: (index) => StatisticsUtils.getBarColor(
        schedules: schedules,
        selectedFilter: selectedFilter,
        day: days[index],
      ),
      isDark: isDark,
    );
  }

  Widget _buildMonthBarChart(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final days = List.generate(daysInMonth, (i) => DateTime(now.year, now.month, i + 1));
    final counts = days.map((day) =>
      schedules.where((s) =>
        s.date.year == day.year && s.date.month == day.month && s.date.day == day.day
      ).length.toDouble()
    ).toList();

    return _buildCustomBarChart(
      context: context,
      labels: List.generate(daysInMonth, (i) => '${i + 1}'),
      values: counts,
      tooltipBuilder: (index) {
        final day = days[index];
        final tasks = schedules.where((s) =>
          s.date.year == day.year && s.date.month == day.month && s.date.day == day.day
        ).toList();
        if (tasks.isEmpty) return 'Không có nhiệm vụ';
        return tasks.map((s) => '${s.title} (${s.time.format(context)})').join('\n');
      },
      getBarColor: (index) => StatisticsUtils.getBarColor(
        schedules: schedules,
        selectedFilter: selectedFilter,
        day: days[index],
      ),
      isDark: isDark,
    );
  }

  Widget _buildYearBarChart(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(12, (i) => i + 1);
    final counts = months.map((month) {
      final tasks = schedules.where((s) =>
        s.date.year == now.year && s.date.month == month
      ).length;
      return tasks.toDouble();
    }).toList();

    return _buildCustomBarChart(
      context: context,
      labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
      values: counts,
      tooltipBuilder: (index) {
        final month = months[index];
        final tasks = schedules.where((s) =>
          s.date.year == now.year && s.date.month == month
        ).toList();
        if (tasks.isEmpty) return 'Không có nhiệm vụ';
        return tasks.map((s) => '${s.title} (${s.date.day}/$month)').join('\n');
      },
      getBarColor: (index) => StatisticsUtils.getBarColor(
        schedules: schedules,
        selectedFilter: selectedFilter,
        month: months[index],
        year: now.year,
      ),
      isDark: isDark,
    );
  }

  Widget _buildSimpleLineChart(BuildContext context) {
    final today = DateTime.now();
    final completedToday = schedules.where((s) =>
      s.date.year == today.year &&
      s.date.month == today.month &&
      s.date.day == today.day
    ).toList();

    final spots = List<FlSpot>.generate(
      completedToday.length,
      (i) => FlSpot(
        completedToday[i].time.hour + completedToday[i].time.minute / 60,
        completedToday[i].tags.length.toDouble(),
      ),
    );

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
            'Nhiệm vụ hoàn thành theo thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 23.99,
                  minY: 0,
                  maxY: (completedToday.isNotEmpty
                      ? completedToday.map((s) => s.tags.length).reduce((a, b) => a > b ? a : b) + 1
                      : 2).toDouble(),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.white12 : Colors.grey[200] ?? Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.white12 : Colors.grey[200] ?? Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0 && value >= 0) {
                            return SizedBox(
                              width: 32,
                              child: Text(
                                '${value.toInt()}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0 && value >= 0 && value <= 23) {
                            return Text(
                              '${value.toInt()}h',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                      left: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: StatisticsUtils.getLineColor(completedToday, selectedFilter),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 7,
                          color: StatisticsUtils.getLineColor(completedToday, selectedFilter),
                          strokeWidth: 2,
                          strokeColor: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipMargin: 24,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final spot = touchedSpot;
                          return LineTooltipItem(
                            StatisticsUtils.getTaskTooltip(completedToday, spot),
                            TextStyle(color: isDark ? Colors.white : Colors.white, fontSize: 14),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBarChart({
    required BuildContext context,
    required List<String> labels,
    required List<double> values,
    required String Function(int) tooltipBuilder,
    required Color Function(int) getBarColor,
    required bool isDark,
  }) {
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
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) + 1 : 5).clamp(5, 999).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 24,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        tooltipBuilder(group.x.toInt()),
                        TextStyle(color: isDark ? Colors.white : Colors.white, fontSize: 14),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                    left: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white12 : Colors.grey[200] ?? Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: List.generate(values.length, (i) =>
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: getBarColor(i),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 5,
                          color: isDark ? Colors.white10 : Colors.grey[100] ?? Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
