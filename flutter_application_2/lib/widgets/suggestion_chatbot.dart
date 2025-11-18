import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/schedule.dart';
import 'package:intl/intl.dart';

class SuggestionChatBot extends StatefulWidget {
  final Schedule? suggestedTask;
  
  const SuggestionChatBot({super.key, this.suggestedTask});

  @override
  State<SuggestionChatBot> createState() => _SuggestionChatBotState();
}

class _SuggestionChatBotState extends State<SuggestionChatBot> {
  // Helper function to generate suggestion reason (can be similar to the one in home_page.dart)
  String _getSuggestionReason(Schedule suggestion) {
    final now = DateTime.now();
    String reason = '';

    if (suggestion.deadline != null && suggestion.deadline!.isBefore(now)) {
      reason = 'Nhiệm vụ này đã quá hạn.';
    } else if (suggestion.priority == 'Cao') {
      reason = 'Nhiệm vụ này có mức độ ưu tiên cao.';
    } else if (suggestion.deadline != null) {
      final remainingTime = suggestion.deadline!.difference(now);
      if (remainingTime.inDays <= 1) {
        reason = 'Nhiệm vụ này có thời hạn hoàn thành rất gần (hôm nay/ngày mai).';
      } else if (remainingTime.inDays <= 3) {
        reason = 'Nhiệm vụ này có thời hạn hoàn thành trong 3 ngày tới.';
      } else {
         reason = 'Nhiệm vụ này có mức ưu tiên ${suggestion.priority ?? 'Thấp'}.';
      }
    } else if (suggestion.priority != null) {
       reason = 'Nhiệm vụ này có mức ưu tiên ${suggestion.priority}.';
    } else {
      reason = 'Đây là một nhiệm vụ chưa hoàn thành.'; // Default reason
    }
    
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestedTask == null) {
      return AlertDialog(
        title: const Text("🤖 Trợ lý ưu tiên"),
        content: const Text("Hiện tại không có gợi ý công việc nào."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      );
    } else {
      final suggestedTask = widget.suggestedTask!;
      final reason = _getSuggestionReason(suggestedTask);

      return AlertDialog(
        title: const Text("🤖 Trợ lý ưu tiên"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tôi gợi ý bạn nên làm nhiệm vụ:\n\"${suggestedTask.title}\"\n"),
            Text(
              "Lý do:\n- $reason",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
             Text(
              'Thời gian: ${DateFormat('HH:mm dd/MM').format(suggestedTask.date)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (suggestedTask.deadline != null)
               Text(
                'Hết hạn: ${DateFormat('HH:mm dd/MM').format(suggestedTask.deadline!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement action to start/view the task
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Bắt đầu"),
          ),
        ],
      );
    }
  }
} 