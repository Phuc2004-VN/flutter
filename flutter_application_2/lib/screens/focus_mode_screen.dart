import 'package:flutter/material.dart';
import 'dart:async'; // Added import for Timer
// Added import for math operations
import 'home_page.dart'; // Added import for HomePage

enum TimerState {
  initial, // Before starting
  working,
  shortBreak,
  longBreak,
  paused,
  finished,
}

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> with TickerProviderStateMixin { // Added TickerProviderStateMixin for animation controller
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // Default work duration: 25 minutes
  TimerState _currentState = TimerState.initial;
  int _pomodoroCount = 0;

  // Durations in seconds (can be made configurable later)
  final int _workDuration = 25 * 60;
  final int _shortBreakDuration = 5 * 60;
  final int _longBreakDuration = 15 * 60;
  final int _pomodoroPerLongBreak = 4;

  late AnimationController _controller; // Animation controller for progress bar

  // Time selection variables (in minutes)
  int _selectedWorkDuration = 25;
  final List<int> _availableWorkDurations = [15, 25, 50]; // Available options in minutes

  @override
  void initState() {
    super.initState();
     _secondsRemaining = _workDuration; // Initialize with work duration
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _workDuration),
    );
    _controller.reverse(
        from: _secondsRemaining == 0 ? 1.0 : _secondsRemaining / _controller.duration!.inSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  void _startTimer() {
    if (_currentState == TimerState.paused) {
       // Continue from paused state
      _currentState = _pomodoroCount % _pomodoroPerLongBreak == 0 && _pomodoroCount > 0
          ? TimerState.longBreak
          : (_pomodoroCount > 0 ? TimerState.shortBreak : TimerState.working);
    } else if (_currentState == TimerState.initial || _currentState == TimerState.finished) {
       // Start a new session
       _currentState = TimerState.working;
       _secondsRemaining = _workDuration;
       _controller.duration = Duration(seconds: _workDuration);
        _controller.reverse(from: 1.0);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
           _controller.value = _secondsRemaining / _controller.duration!.inSeconds; // Update animation controller value
        });
      } else {
        _timer?.cancel();
        _pomodoroCount++;

        if (_currentState == TimerState.working) {
          // Finished a work session, transition to break
          if (_pomodoroCount % _pomodoroPerLongBreak == 0) {
            _currentState = TimerState.longBreak;
            _secondsRemaining = _longBreakDuration;
             _controller.duration = Duration(seconds: _longBreakDuration);
          } else {
            _currentState = TimerState.shortBreak;
            _secondsRemaining = _shortBreakDuration;
            _controller.duration = Duration(seconds: _shortBreakDuration);
          }
           _controller.reverse(from: 1.0);
           _startTimer(); // Start break timer
        } else if (_currentState == TimerState.shortBreak || _currentState == TimerState.longBreak) {
          // Finished a break, transition back to work
           _currentState = TimerState.working;
           _secondsRemaining = _workDuration;
           _controller.duration = Duration(seconds: _workDuration);
           _controller.reverse(from: 1.0);
           _startTimer(); // Start next work timer
        }

         // Optional: If finished a certain number of cycles, can transition to finished state
         // For simplicity, this basic version keeps cycling work/breaks

      }
    });
     setState(() {}); // Update UI to reflect state change (e.g., button visibility)
  }

  void _pauseTimer() {
    _timer?.cancel();
     setState(() {
       _currentState = TimerState.paused;
     });
     _controller.stop(); // Stop animation controller
  }

  void _resetTimer() {
    _timer?.cancel();
     _controller.reset(); // Reset animation controller
    setState(() {
      _secondsRemaining = _workDuration;
      _currentState = TimerState.initial;
      _pomodoroCount = 0;
       _controller.duration = Duration(seconds: _workDuration);
       _controller.reverse(from: 1.0); // Start animation from beginning
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String _getCurrentStateText() {
    switch (_currentState) {
      case TimerState.initial:
        return 'Sẵn sàng làm việc';
      case TimerState.working:
        return 'Đang làm việc';
      case TimerState.shortBreak:
        return 'Nghỉ ngắn';
      case TimerState.longBreak:
        return 'Nghỉ dài';
      case TimerState.paused:
        return 'Tạm dừng';
      case TimerState.finished:
        return 'Hoàn thành';
    }
  }

   Color _getTimerColor() {
     switch (_currentState) {
       case TimerState.working:
         return Colors.blue.shade700;
       case TimerState.shortBreak:
         return Colors.green.shade700;
       case TimerState.longBreak:
         return Colors.teal.shade700;
       case TimerState.paused:
         return Colors.orange.shade700;
       case TimerState.initial:
       case TimerState.finished:
         return Colors.grey.shade600;
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          tooltip: 'Quay lại trang chủ',
        ),
        title: const Text('Chế độ tập trung'),
      ),
      backgroundColor: Colors.blue.shade50, // Added background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentState == TimerState.initial || _currentState == TimerState.finished)
              DropdownButton<int>(
                value: _selectedWorkDuration,
                items: _availableWorkDurations.map((int duration) {
                  return DropdownMenuItem<int>(
                    value: duration,
                    child: Text('$duration phút'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWorkDuration = newValue;
                      _secondsRemaining = _selectedWorkDuration * 60; // Update timer display
                      _controller.duration = Duration(seconds: _secondsRemaining); // Update animation duration
                      _controller.reverse(from: 1.0); // Reset animation
                    });
                  }
                },
              ),
            Text(
              _getCurrentStateText(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getTimerColor()), // Dynamic color
            ),
            const SizedBox(height: 40), // Increased spacing
            Stack(
              alignment: Alignment.center,
              children: [
                 // Circular Progress Indicator
                 SizedBox(
                   width: 250,
                   height: 250,
                   child: CircularProgressIndicator(
                     value: _controller.value, // Use animation controller value
                     strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()), // Dynamic color
                   ),
                 ),
                 // Time Text
                 Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: _getTimerColor()), // Dynamic color
                ),
              ],
            ),
            const SizedBox(height: 40), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentState == TimerState.initial || _currentState == TimerState.paused || _currentState == TimerState.finished)
                  Tooltip(
                     message: _currentState == TimerState.initial ? 'Bắt đầu phiên làm việc' : 'Tiếp tục đếm ngược',
                    child: ElevatedButton.icon(
                       onPressed: _startTimer,
                       icon: Icon(_currentState == TimerState.initial ? Icons.play_arrow : Icons.play_arrow), // Changed icon
                       label: Text(_currentState == TimerState.initial ? 'Bắt đầu' : 'Tiếp tục'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue.shade600,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                         textStyle: const TextStyle(fontSize: 18),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                       ),
                     ),
                   ),
                if (_currentState == TimerState.working || _currentState == TimerState.shortBreak || _currentState == TimerState.longBreak)
                  Tooltip(
                     message: 'Tạm dừng bộ đếm thời gian',
                    child: ElevatedButton.icon(
                       onPressed: _pauseTimer,
                       icon: const Icon(Icons.pause), // Changed icon
                       label: const Text('Tạm dừng'),
                        style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.orange.shade600,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                         textStyle: const TextStyle(fontSize: 18),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                       ),
                     ),
                   ),
                const SizedBox(width: 20),
                 Tooltip(
                   message: 'Đặt lại bộ đếm thời gian và số Pomodoro',
                   child: ElevatedButton.icon(
                     onPressed: _resetTimer,
                     icon: const Icon(Icons.refresh), // Changed icon
                     label: const Text('Đặt lại'),
                      style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.red.shade600,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       textStyle: const TextStyle(fontSize: 18),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                     ),
                   ),
                 ),
              ],
            ),
             const SizedBox(height: 40), // Increased spacing
             Text(
               'Số Pomodoro đã hoàn thành: $_pomodoroCount',
                style: const TextStyle(fontSize: 18),
             ),
          ],
        ),
      ),
    );
  }
} 