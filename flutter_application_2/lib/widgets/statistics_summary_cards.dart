import 'package:flutter/material.dart';

class StatisticsSummaryCards extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int upcomingTasks;
  final bool isDark;

  const StatisticsSummaryCards({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
    required this.upcomingTasks,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Tổng số nhiệm vụ',
            totalTasks.toString(),
            Icons.assignment,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 14),  
        Expanded(
          child: _buildSummaryCard(
            'Đã hoàn thành',
            completedTasks.toString(),
            Icons.check_circle,
            Colors.green,
            isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSummaryCard(
            'Sắp tới',
            upcomingTasks.toString(),
            Icons.upcoming,
            Colors.orange,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
