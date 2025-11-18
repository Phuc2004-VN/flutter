import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../utils/tag_manager.dart';
import '../utils/time_utils.dart';
import '../models/schedule.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final Function(int) onEditSchedule;
  final Function(int) onDeleteSchedule;
  final Function(int) onToggleComplete;

  const ScheduleList({
    Key? key,
    required this.schedules,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: schedules.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(schedule.date),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      TimeUtils.formatTimeOfDay(schedule.time),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                if (schedule.priority != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.priority_high_rounded, size: 16, color: Colors.orange.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Mức độ ưu tiên: ${schedule.priority}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (schedule.deadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded, size: 16, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Thời hạn: ${DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(schedule.deadline!)}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (schedule.attachments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attachment, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${schedule.attachments.length}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        schedule.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                        color: schedule.isCompleted ? Colors.green.shade700 : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () => onToggleComplete(index),
                      tooltip: schedule.isCompleted ? 'Đánh dấu chưa hoàn thành' : 'Đánh dấu hoàn thành',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                      onPressed: () => onEditSchedule(index),
                      tooltip: 'Chỉnh sửa lịch trình',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => onDeleteSchedule(index),
                      tooltip: 'Xóa lịch trình',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final File pdfFile;

  const PDFViewerScreen({required this.pdfFile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xem PDF")),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }
}
