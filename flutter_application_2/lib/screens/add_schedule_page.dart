import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/description_tag_section.dart';
import '../utils/time_utils.dart';
import '../models/schedule.dart'; // Import the Schedule model
import 'package:path/path.dart' as path;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class AddSchedulePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddSchedulePage({super.key, this.initialData});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _selectedTags = [];
  List<Map<String, String>> _attachments = []; // Cập nhật kiểu dữ liệu
  String? _selectedPriority; // State variable for priority
  DateTime? _selectedDeadline; // State variable for deadline
  String? _description; // Thêm biến state cho mô tả

  late final SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _voiceTranscript = '';
  String? _voiceHint;

  final List<String> _priorities = ['Cao', 'Trung bình', 'Thấp']; // Priority options

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _initSpeech();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      _description = widget.initialData!['description'] ?? ''; // Khởi tạo biến state
      if (widget.initialData!['tags'] != null) {
        final tags = widget.initialData!['tags'];
        if (tags is String) {
          _selectedTags = tags
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        } else if (tags is List) {
          _selectedTags = tags
              .map((tag) => tag.toString().trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      }
      // Cập nhật xử lý file đính kèm từ initialData
      if (widget.initialData!['attachments'] != null) {
        final attachments = widget.initialData!['attachments'];
        if (attachments is List) {
          _attachments = attachments.map((attachment) {
            // Giả định attachment trong initialData là map có 'path' và 'name'
            if (attachment is Map<String, dynamic>) {
              return {
                'path': attachment['path'].toString(),
                'name': attachment['name'].toString(),
              };
            } else {
              // Xử lý trường hợp dữ liệu cũ chỉ có đường dẫn (nếu cần)
              return {
                'path': attachment.toString(),
                'name': path.basename(attachment.toString()),
              };
            }
          }).toList();
        }
      }
      _selectedPriority = widget.initialData!['priority'];
      if (widget.initialData!['deadline'] != null) {
        _selectedDeadline = DateTime.parse(widget.initialData!['deadline']);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speechToText.initialize(
        onStatus: (status) {
          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (SpeechRecognitionError errorNotification) {
          setState(() {
            _isListening = false;
            _voiceHint = 'Lỗi micro: ${errorNotification.errorMsg}';
          });
        },
        debugLogging: false,
      );
      setState(() {
        _speechEnabled = available;
        if (!available) {
          _voiceHint = 'Không thể khởi tạo microphone, kiểm tra quyền truy cập.';
        }
      });
    } catch (e) {
      setState(() {
        _speechEnabled = false;
        _voiceHint = 'Không thể khởi tạo microphone: $e';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
    }
    if (!_speechEnabled) return;
    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _voiceHint = 'Đang lắng nghe... hãy nói rõ tiêu đề, mô tả, ưu tiên, ngày giờ.';
      });
      await _speechToText.listen(
        localeId: 'vi_VN',
        onResult: _handleSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      );
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _voiceTranscript = result.recognizedWords;
    });
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      _handleVoiceCommand(result.recognizedWords);
    }
  }

  static const List<String> _voiceKeywords = [
    'tiêu đề',
    'mô tả',
    'uu tien',
    'ưu tiên',
    'ngày',
    'giờ',
    'deadline',
    'thời hạn',
    'kết thúc',
    'ngay',
    'gio'
  ];

  void _handleVoiceCommand(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;
    final lower = text.toLowerCase();
    bool hasUpdate = false;

    String? title = _extractValueByKeyword(text, lower, const ['tiêu đề', 'title', 'tạo lịch', 'tao lich']);
    if (title != null && title.isNotEmpty) {
      setState(() {
        _titleController.text = _capitalizeSentence(title);
      });
      hasUpdate = true;
    }

    final description = _extractValueByKeyword(text, lower, const ['mô tả', 'mo ta', 'nội dung', 'noi dung']);
    if (description != null && description.isNotEmpty) {
      setState(() {
        _descriptionController.text = description.trim();
      });
      hasUpdate = true;
    }

    if (lower.contains('ưu tiên cao') || lower.contains('uu tien cao')) {
      setState(() => _selectedPriority = 'Cao');
      hasUpdate = true;
    } else if (lower.contains('ưu tiên trung bình') || lower.contains('uu tien trung binh')) {
      setState(() => _selectedPriority = 'Trung bình');
      hasUpdate = true;
    } else if (lower.contains('ưu tiên thấp') || lower.contains('uu tien thap')) {
      setState(() => _selectedPriority = 'Thấp');
      hasUpdate = true;
    }

    final dateFromVoice = _parseDateFromText(lower);
    final timeFromVoice = _parseTimeFromText(lower);
    if (dateFromVoice != null || timeFromVoice != null) {
      _applyDeadlineFromVoice(date: dateFromVoice, time: timeFromVoice);
      hasUpdate = true;
    }

    if (!hasUpdate && _titleController.text.trim().isEmpty) {
      setState(() {
        _titleController.text = _capitalizeSentence(text);
      });
    } else if (!hasUpdate && _descriptionController.text.trim().isEmpty) {
      setState(() {
        _descriptionController.text = text;
      });
    }

    if (lower.contains('lưu lịch') || lower.contains('luu lich') || lower.contains('hoàn tất') || lower.contains('xong rồi')) {
      _onSave();
    }

    setState(() {
      _voiceHint = 'Đã nhận: "$text"';
    });
  }

  String? _extractValueByKeyword(String original, String lower, List<String> keywords) {
    for (final keyword in keywords) {
      final index = lower.indexOf(keyword);
      if (index != -1) {
        final start = index + keyword.length;
        if (start >= original.length) continue;
        final remainder = original.substring(start).trim();
        final boundaryIndex = _findBoundaryIndex(remainder.toLowerCase());
        final segment = (boundaryIndex == -1 ? remainder : remainder.substring(0, boundaryIndex)).trim();
        final cleaned = segment.replaceAll(RegExp(r'^[,.: ]+'), '').replaceAll(RegExp(r'[,.: ]+$'), '');
        if (cleaned.isNotEmpty) {
          return cleaned;
        }
      }
    }
    return null;
  }

  int _findBoundaryIndex(String lowerRemainder) {
    int boundaryIndex = -1;
    for (final boundary in _voiceKeywords) {
      final idx = lowerRemainder.indexOf(boundary);
      if (idx != -1) {
        if (boundaryIndex == -1 || idx < boundaryIndex) {
          boundaryIndex = idx;
        }
      }
    }
    return boundaryIndex;
  }

  DateTime? _parseDateFromText(String lower) {
    final now = DateTime.now();
    if (lower.contains('hôm nay') || lower.contains('hom nay')) {
      return DateTime(now.year, now.month, now.day);
    }
    if (lower.contains('ngày mai') || lower.contains('ngay mai')) {
      final date = now.add(const Duration(days: 1));
      return DateTime(date.year, date.month, date.day);
    }
    if (lower.contains('ngày mốt') || lower.contains('ngay mot')) {
      final date = now.add(const Duration(days: 2));
      return DateTime(date.year, date.month, date.day);
    }

    final weekdayMatch = RegExp(r'thứ\s*(\d)', caseSensitive: false).firstMatch(lower);
    if (weekdayMatch != null) {
      final weekday = int.tryParse(weekdayMatch.group(1)!);
      if (weekday != null) {
        final currentWeekday = now.weekday;
        int diff = weekday - currentWeekday;
        if (diff <= 0) diff += 7;
        final date = now.add(Duration(days: diff));
        return DateTime(date.year, date.month, date.day);
      }
    }

    final dateMatch = RegExp(r'(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?').firstMatch(lower);
    if (dateMatch != null) {
      final day = int.tryParse(dateMatch.group(1)!);
      final month = int.tryParse(dateMatch.group(2)!);
      final yearGroup = dateMatch.group(3);
      final year = yearGroup != null ? int.tryParse(yearGroup.length == 2 ? '20$yearGroup' : yearGroup) : now.year;
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  TimeOfDay? _parseTimeFromText(String lower) {
    final timeMatch = RegExp(r'(\d{1,2})(?:[:h](\d{1,2}))?\s*(?:giờ|h)\s*(sáng|trưa|chiều|tối|đêm|am|pm)?').firstMatch(lower);
    if (timeMatch == null) return null;
    int hour = int.tryParse(timeMatch.group(1) ?? '') ?? 0;
    final minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
    final meridiem = timeMatch.group(3);

    if (meridiem != null) {
      if ((meridiem.contains('chiều') || meridiem.contains('tối') || meridiem.contains('đêm') || meridiem == 'pm') && hour < 12) {
        hour += 12;
      } else if ((meridiem.contains('sáng') || meridiem == 'am') && hour == 12) {
        hour = 0;
      } else if (meridiem.contains('trưa') && hour < 12) {
        hour = 12;
      }
    }

    hour = hour % 24;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _applyDeadlineFromVoice({DateTime? date, TimeOfDay? time}) {
    final now = DateTime.now();
    final current = _selectedDeadline ?? DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final targetDate = date ??
        DateTime(
          current.year,
          current.month,
          current.day,
        );
    final targetTime = time ??
        TimeOfDay(
          hour: current.hour,
          minute: current.minute,
        );

    setState(() {
      _selectedDeadline = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        targetTime.hour,
        targetTime.minute,
      );
    });
  }

  String _capitalizeSentence(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }


  void _selectDeadlineDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDeadline?.hour ?? 0,
          _selectedDeadline?.minute ?? 0,
        );
      });
    }
  }

  void _selectDeadlineTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDeadline != null ? TimeOfDay.fromDateTime(_selectedDeadline!) : TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDeadline = DateTime(
          _selectedDeadline?.year ?? DateTime.now().year,
          _selectedDeadline?.month ?? DateTime.now().month,
          _selectedDeadline?.day ?? DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Khi nhấn nút Lưu
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newSchedule = Schedule(
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _selectedTags,
        priority: _selectedPriority,
        date: DateTime.now(),
        time: TimeOfDay.now(),
        deadline: _selectedDeadline,
        isCompleted: false,
        attachments: _attachments, // Truyền danh sách map
      );
      Navigator.pop(context, newSchedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleListening,
        backgroundColor: !_speechEnabled
            ? Colors.grey
            : (_isListening ? Colors.redAccent : Colors.blueAccent),
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
        label: Text(_isListening ? 'Đang lắng nghe' : 'Nói để tạo lịch'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey.shade900, Colors.grey.shade800, Colors.black]
                : [Colors.blue.shade800, Colors.blue.shade500, Colors.blue.shade50],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.initialData != null ? 'Chỉnh sửa lịch trình' : 'Thêm lịch trình mới',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_voiceHint != null || _voiceTranscript.isNotEmpty)
                      _buildVoiceStatusCard(isDark),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Tiêu đề',
                                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
                                    prefixIcon: Icon(Icons.title_rounded, color: Colors.blue.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tiêu đề';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                                  ),
                                  child: DescriptionTagSection(
                                    descriptionController: _descriptionController,
                                    selectedTags: _selectedTags,
                                    currentAttachments: _attachments,
                                    onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                                    onAttachmentsChanged: (attachments) => setState(() => _attachments = attachments),
                                    onDescriptionChanged: (value) { // Cập nhật biến state khi mô tả thay đổi
                                      setState(() {
                                        _description = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildPrioritySection(isDark),
                                const SizedBox(height: 24),
                                _buildDeadlineSection(isDark),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.initialData != null ? 'Cập nhật' : 'Thêm mới',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceStatusCard(bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black87;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening ? Colors.redAccent : Colors.blueAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _voiceHint ?? (_isListening ? 'Đang nghe bạn...' : 'Nhấn micro để bắt đầu'),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_voiceTranscript.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$_voiceTranscript"',
              style: TextStyle(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrioritySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mức độ ưu tiên',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: InputDecoration(
            hintText: 'Chọn mức độ ưu tiên',
            hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
            prefixIcon: Icon(Icons.priority_high_rounded, color: Colors.blue.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
          dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: _priorities.map((String priority) {
            return DropdownMenuItem<String>(
              value: priority,
              child: Text(priority),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPriority = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn mức độ ưu tiên';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeadlineSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời hạn hoàn thành',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                onTap: _selectDeadlineDate,
                decoration: InputDecoration(
                  hintText: _selectedDeadline != null
                      ? DateFormat('dd/MM/yyyy', 'vi_VN').format(_selectedDeadline!)
                      : 'Chọn ngày hết hạn',
                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
                  prefixIcon: Icon(Icons.event_rounded, color: Colors.blue.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                onTap: _selectDeadlineTime,
                decoration: InputDecoration(
                  hintText: _selectedDeadline != null
                      ? TimeUtils.formatTimeOfDay(TimeOfDay.fromDateTime(_selectedDeadline!))
                      : 'Chọn giờ hết hạn',
                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
                  prefixIcon: Icon(Icons.access_time_rounded, color: Colors.blue.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}