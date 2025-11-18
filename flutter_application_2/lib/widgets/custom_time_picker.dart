import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay _selectedTime;
  bool _isAM = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _isAM = _selectedTime.hour < 12;
  }

  void _updateTime(int hour, int minute) {
    final adjustedHour = _isAM ? hour : (hour == 12 ? 12 : hour + 12);
    final newTime = TimeOfDay(hour: adjustedHour, minute: minute);
    setState(() {
      _selectedTime = newTime;
    });
    widget.onTimeChanged(newTime);
  }

  void _toggleAMPM() {
    setState(() {
      _isAM = !_isAM;
      final currentHour = _selectedTime.hour;
      final newHour = _isAM ? currentHour - 12 : currentHour + 12;
      if (newHour >= 0 && newHour < 24) {
        _updateTime(newHour % 12 == 0 ? 12 : newHour % 12, _selectedTime.minute);
      }
    });
  }

  void _incrementHour() {
    final newHour = (_selectedTime.hourOfPeriod % 12) + 1;
    _updateTime(newHour == 13 ? 1 : newHour, _selectedTime.minute);
  }

  void _decrementHour() {
    final newHour = (_selectedTime.hourOfPeriod - 1) <= 0 ? 12 : (_selectedTime.hourOfPeriod - 1);
    _updateTime(newHour, _selectedTime.minute);
  }

  void _incrementMinute() {
    final newMinute = (_selectedTime.minute + 1) % 60;
    _updateTime(_selectedTime.hourOfPeriod, newMinute);
  }

  void _decrementMinute() {
    final newMinute = (_selectedTime.minute - 1) < 0 ? 59 : (_selectedTime.minute - 1);
    _updateTime(_selectedTime.hourOfPeriod, newMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeSection(
                value: _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod,
                label: 'Giờ',
                onIncrement: _incrementHour,
                onDecrement: _decrementHour,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withValues(alpha:0.8),
                  ),
                ),
              ),
              _buildTimeSection(
                value: _selectedTime.minute,
                label: 'Phút',
                onIncrement: _incrementMinute,
                onDecrement: _decrementMinute,
              ),
              const SizedBox(width: 16),
              _buildAMPMToggle(),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickMinuteSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeSection({
    required int value,
    required String label,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_up, color: Colors.blue.shade700),
            onPressed: onIncrement,
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue.shade700),
            onPressed: onDecrement,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAMPMToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleAMPM,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Text(
                  'AM',
                  style: TextStyle(
                    color: _isAM ? Colors.white : Colors.white.withValues(alpha:0.5),
                    fontWeight: _isAM ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 20,
                  color: Colors.white.withValues(alpha:0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  'PM',
                  style: TextStyle(
                    color: !_isAM ? Colors.white : Colors.white.withValues(alpha:0.5),
                    fontWeight: !_isAM ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMinuteSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [0, 15, 30, 45].map((minute) {
          final isSelected = _selectedTime.minute == minute;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateTime(_selectedTime.hourOfPeriod, minute),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  minute.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 