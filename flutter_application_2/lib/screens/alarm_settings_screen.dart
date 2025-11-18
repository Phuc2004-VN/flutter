import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/custom_time_picker.dart';

class AlarmSettingsScreen extends StatefulWidget {
  const AlarmSettingsScreen({super.key});

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  bool _isAlarmEnabled = true;
  TimeOfDay _alarmTime = const TimeOfDay(hour: 7, minute: 0);
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  String _selectedSound = 'Báo thức mặc định';
  bool _isVibrationEnabled = true;
  bool _isSnoozeEnabled = true;
  int _snoozeDuration = 5;

  final List<String> _weekDays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  final List<String> _alarmSounds = [
    'Báo thức mặc định',
    'Tiếng chuông',
    'Nhạc nhẹ',
    'Tiếng chim hót',
    'Tiếng sóng biển',
  ];

  Future<void> _showTimePicker() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn thời gian báo thức'),
        content: SizedBox(
          width: double.maxFinite,
          child: CustomTimePicker(
            initialTime: _alarmTime,
            onTimeChanged: (time) {
              setState(() {
                _alarmTime = time;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã cập nhật thời gian báo thức: ${_formatTime(_alarmTime)}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt báo thức',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bật báo thức',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: _isAlarmEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isAlarmEnabled = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        if (_isAlarmEnabled) ...[
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'Thời gian báo thức',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _showTimePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatTime(_alarmTime),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nhấn để chọn thời gian báo thức',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lặp lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            return ChoiceChip(
                              label: Text(_weekDays[index]),
                              selected: _selectedDays[index],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDays[index] = selected;
                                });
                              },
                              selectedColor: Colors.blue.withValues(alpha:0.2),
                              backgroundColor: Colors.grey.withValues(alpha:0.1),
                              labelStyle: TextStyle(
                                color: _selectedDays[index] ? Colors.blue : Colors.black,
                                fontWeight: _selectedDays[index] ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Âm thanh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSound,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.music_note),
                          ),
                          items: _alarmSounds.map((sound) {
                            return DropdownMenuItem(
                              value: sound,
                              child: Text(sound),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSound = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Rung'),
                            Switch(
                              value: _isVibrationEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isVibrationEnabled = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Báo lại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: _isSnoozeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isSnoozeEnabled = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        if (_isSnoozeEnabled) ...[
                          const SizedBox(height: 16),
                          const Text('Thời gian báo lại (phút)'),
                          Slider(
                            value: _snoozeDuration.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_snoozeDuration phút',
                            onChanged: (value) {
                              setState(() {
                                _snoozeDuration = value.round();
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Lưu cài đặt báo thức
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu cài đặt',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 