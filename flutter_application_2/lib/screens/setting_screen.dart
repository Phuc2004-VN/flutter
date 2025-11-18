import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/auth/login_page.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../widgets/badges_section.dart';
import '../providers/theme_provider.dart';
import '../providers/setting_provider.dart';

class SettingScreen extends StatefulWidget {
  final int selectedTab;
  final int? profileTab; // 0: Quản lý tài khoản, 1: Thông tin cá nhân
  const SettingScreen({Key? key, this.selectedTab = 0, this.profileTab}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _selectedIndex = 0;
  int _profileTab = 0;
  bool _notificationEnabled = true;
  bool _reminderBeforeDeadlineEnabled = true;
  int _reminderMinutesBefore = 15;
  bool _dailySummaryEnabled = false;

  String _selectedBackgroundColorName = 'Mặc định sáng';

  // Thông tin user thực tế
  int? _userId;
  String _avatarUrl = '';
  String _name = '';
  String _dob = '';
  String _gender = '';
  String _email = '';
  String _phone = '';

  // Biến tạm khi chỉnh sửa
  String? _editAvatarUrl;
  String? _editName;
  String? _editDob;
  String? _editGender;
  String? _editEmail;
  String? _editPhone;

  bool _isLoadingUser = true;
  bool _isSaving = false;

  final List<String> _menuTitles = [
    'Giao diện',
    'Thông báo',
    'Quản lý tài khoản',
    'Huy hiệu',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedTab;
    _profileTab = widget.profileTab ?? 0;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('logged_in_user_id');
    final token = prefs.getString('auth_token');
    if (userId == null || token == null) {
      setState(() => _isLoadingUser = false);
      return;
    }
    _userId = userId;
    try {
      final res = await http.get(
        Uri.parse('http://localhost:4567/api/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _avatarUrl = data['avatar_url'] ?? '';
          _name = data['username'] ?? '';
          _dob = _formatDob(data['dob'] ?? '');
          _gender = data['gender'] ?? '';
          _email = data['email'] ?? '';
          _phone = data['phone'] ?? '';
          _editAvatarUrl = _avatarUrl;
          _editName = _name;
          _editDob = _dob;
          _editGender = _gender;
          _editEmail = _email;
          _editPhone = _phone;
          _isLoadingUser = false;
        });
      } else {
        setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      setState(() => _isLoadingUser = false);
    }
  }

  Future<void> _saveUserInfo() async {
    if (_userId == null) return;
    setState(() => _isSaving = true);

    // Chỉ gửi các trường thay đổi
    final Map<String, dynamic> updateData = {};
    if (_editName != _name) updateData['username'] = _editName;
    if (_editEmail != _email) updateData['email'] = _editEmail;
    if (_editAvatarUrl != _avatarUrl) updateData['avatar_url'] = _editAvatarUrl;
    if (_editDob != _dob) updateData['dob'] = _editDob;
    if (_editGender != _gender) updateData['gender'] = _editGender;
    if (_editPhone != _phone) updateData['phone'] = _editPhone;

    if (updateData.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thay đổi nào để lưu.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn cần đăng nhập lại để cập nhật thông tin.')),
          );
        }
        return;
      }

      final res = await http.put(
        Uri.parse('http://localhost:4567/api/user/$_userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );
      if (res.statusCode == 200) {
        setState(() {
          _avatarUrl = _editAvatarUrl ?? '';
          _name = _editName ?? '';
          _dob = _editDob ?? '';
          _gender = _editGender ?? '';
          _email = _editEmail ?? '';
          _phone = _editPhone ?? '';
        });
        // Cập nhật thông tin trong SharedPreferences
        await prefs.setString('user_avatar', _avatarUrl);
        await prefs.setString('user_name', _name);
        await prefs.setString('logged_in_username', _editName ?? '');
        await prefs.setString('logged_in_email', _editEmail ?? '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${json.decode(res.body)['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.blue.shade800,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : Colors.blue.shade200.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cài đặt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(_menuTitles.length, (i) => _buildMenuItem(i, isDark)),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              color: isDark ? Colors.black : Colors.blue.shade50,
              child: _buildContent(isDark),
            ),
          ),
        ],
      ),
      floatingActionButton: _profileTab == 1
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveUserInfo,
              backgroundColor: Colors.blue.shade700,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Text('Lưu'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMenuItem(int index, bool isDark) {
    bool selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      hoverColor: isDark ? Colors.blue.shade800.withOpacity(0.3) : Colors.blue.shade50.withOpacity(0.9),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? (isDark ? Colors.blue.shade900 : Colors.blue.shade600) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              index == 0
                  ? Icons.color_lens
                  : index == 1
                      ? Icons.notifications
                      : index == 2
                          ? Icons.person
                          : Icons.emoji_events,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              _menuTitles[index],
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (_selectedIndex) {
            0 => _buildAppearanceSettings(isDark),
            1 => _buildNotificationSettings(isDark),
            2 => _buildAccountSettings(isDark),
            3 => const BadgesSection(),
            _ => Container(),
          },
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Define available solid background color options and their names
    final Map<String, Color> backgroundColorOptions = {
      'Mặc định sáng': Colors.blue.shade50, // Default light background
      'Mặc định tối': Colors.black, // Default dark background
      'Trắng': Colors.white,
      'Đen': Colors.black,
      'Xám nhạt': Colors.grey.shade200,
      'Xanh dương nhạt': Colors.blue.shade100,
      // Add more solid color options as needed
    };

    // Update local state based on the provider's current background color
    String currentBackgroundColorName = backgroundColorOptions.entries
        .firstWhere(
            (entry) => entry.value.value == themeProvider.selectedBackgroundColor.value,
            orElse: () => isDark
                ? const MapEntry('Mặc định tối', Colors.black)
                : MapEntry('Mặc định sáng', Colors.blue.shade50) // Default based on theme
        )
        .key;
    // We don't need to setState here, as the RadioListTile will update based on groupValue from the provider
    _selectedBackgroundColorName = currentBackgroundColorName; // Keep local state in sync for initial build

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Giao diện',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.brightness_6, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 16),
                Text('Chế độ sáng/tối', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                const Spacer(),
                Switch(
                  value: themeProvider.isDarkMode,
                  activeColor: Colors.blue.shade700,
                  onChanged: (val) {
                    themeProvider.toggleTheme(val);
                    // TODO: Save theme preference is handled by ThemeProvider
                  },
                ),
              ],
            ),

            const SizedBox(height: 32), // Space between sections

            Text(
              'Màu nền',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: backgroundColorOptions.entries.map((entry) {
                final backgroundName = entry.key;
                final backgroundColor = entry.value;
                return RadioListTile<String>(
                  title: Text(backgroundName, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  value: backgroundName, // Use background color name as the value
                  groupValue: _selectedBackgroundColorName,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Find the color corresponding to the selected name
                      final selectedColor = backgroundColorOptions[newValue];
                      if (selectedColor != null) {
                        themeProvider.setBackgroundColor(selectedColor);
                        // No need for local setState, provider will handle UI update
                      }
                    }
                  },
                   activeColor: themeProvider.selectedColor, // Use the selected theme color
                   controlAffinity: ListTileControlAffinity.leading,
                   dense: true,
                );
              }).toList(),
            ),

            // TODO: Add options for custom sounds later

          ],
        ),
      ),
      ),
    );
  }

  Widget _buildNotificationSettings(bool isDark) {
  final notificationProvider = Provider.of<NotificationSettingsProvider>(context);
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    color: isDark ? Colors.grey.shade900 : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 16),
                     Text('Nhắc nhở lịch trình chung', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              Switch(
                value: notificationProvider.notificationEnabled,
                activeColor: Colors.blue.shade700,
                onChanged: (val) => notificationProvider.setNotificationEnabled(val),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Bật/tắt tất cả thông báo nhắc nhở lịch trình.', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey)),
          
          const SizedBox(height: 32), // Add space between sections

          Text(
            'Nhắc nhở trước thời hạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                 children: [
                   Icon(Icons.timer, color: Colors.orange.shade700, size: 28),
                   const SizedBox(width: 16),
                   Text('Nhắc nhở trước thời hạn', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                 ],
               ),
               Switch(
                 value: notificationProvider.reminderBeforeDeadlineEnabled,
                 activeColor: Colors.orange.shade700,
                 onChanged: (val) => notificationProvider.setReminderBeforeDeadlineEnabled(val),
               ),
            ],
          ),
          if (notificationProvider.reminderBeforeDeadlineEnabled) ...[
            const SizedBox(height: 16),
            Text(
              'Nhắc nhở trước (phút):',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade800),
            ),
            Slider(
              value: notificationProvider.reminderMinutesBefore.toDouble(),
              min: 5,
              max: 60,
              divisions: 11, // 5, 10, 15, ..., 60
              label: '${notificationProvider.reminderMinutesBefore} phút',
              onChanged: (val) => notificationProvider.setReminderMinutesBefore(val.round()),
            ),
             Text('Bạn sẽ nhận được thông báo ${notificationProvider.reminderMinutesBefore} phút trước thời hạn của lịch trình.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
          ],
          
           const SizedBox(height: 32), // Add space between sections

          Text(
            'Thông báo hàng ngày',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                 children: [
                   Icon(Icons.calendar_today, color: Colors.teal.shade700, size: 28),
                   const SizedBox(width: 16),
                   Text('Tóm tắt lịch trình hàng ngày', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                 ],
               ),
               Switch(
                 value: _dailySummaryEnabled,
                 activeColor: Colors.teal.shade700,
                 onChanged: (val) {
                   setState(() => _dailySummaryEnabled = val);
                   // TODO: Thêm logic bật/tắt tóm tắt hàng ngày
                 },
               ),
            ],
          ),
           const SizedBox(height: 16),
           Text('Nhận thông báo tóm tắt các lịch trình trong ngày vào mỗi buổi sáng.', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey)),

        ],
      ),
    ),
  );
}

  Widget _buildAccountSettings(bool isDark) {
    if (_profileTab == 1) {
      return _buildProfileInfo(isDark);
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý tài khoản',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue.shade700),
              title: Text('Thông tin cá nhân', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              subtitle: Text('Xem và chỉnh sửa thông tin cá nhân', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
              onTap: () {
                setState(() => _profileTab = 1);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_reset, color: Colors.blue.shade700, size: 32),
              title: Text(
                'Đổi mật khẩu',
                style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white54 : Colors.grey),
              onTap: () {
                _showChangePasswordDialog(isDark);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text('Đăng xuất', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(bool isDark) {
    if (_isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
                onPressed: () {
                  setState(() {
                    _profileTab = 0;
                  });
                },
              ),
              Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bỏ Expanded, chỉ dùng Card và Column
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: isDark ? Colors.grey.shade900 : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin cơ bản', isDark),
                  const SizedBox(height: 16),
                  _buildProfileRow(
                    context,
                    label: 'Ảnh hồ sơ',
                    valueWidget: CircleAvatar(radius: 28, backgroundImage: NetworkImage(_editAvatarUrl ?? '')),
                    onEdit: () => _showEditAvatarDialog(isDark),
                    isDark: isDark,
                  ),
                  _buildProfileRow(
                    context,
                    label: 'Tên',
                    value: _editName ?? '',
                    onEdit: () => _showEditTextDialog('Tên', _editName ?? '', (val) => setState(() => _editName = val), isDark),
                    isDark: isDark,
                  ),
                  _buildProfileRow(
                    context,
                    label: 'Ngày sinh',
                    value: _editDob ?? '',
                    onEdit: () => _showEditTextDialog('Ngày sinh', _editDob ?? '', (val) => setState(() => _editDob = val), isDark),
                    isDark: isDark,
                  ),
                  _buildProfileRow(
                    context,
                    label: 'Giới tính',
                    value: _editGender ?? '',
                    onEdit: () => _showEditGenderDialog(isDark),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: isDark ? Colors.grey.shade900 : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Thông tin liên hệ', isDark),
                  const SizedBox(height: 16),
                  _buildProfileRow(
                    context,
                    label: 'Email',
                    value: _editEmail ?? '',
                    onEdit: () => _showEditTextDialog('Email', _editEmail ?? '', (val) => setState(() => _editEmail = val), isDark),
                    isDark: isDark,
                  ),
                  _buildProfileRow(
                    context,
                    label: 'Số điện thoại',
                    value: _editPhone ?? '',
                    onEdit: () => _showEditTextDialog('Số điện thoại', _editPhone ?? '', (val) => setState(() => _editPhone = val), isDark),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context, {required String label, String? value, Widget? valueWidget, required VoidCallback onEdit, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800, fontSize: 16))),
          Expanded(
            child: valueWidget ?? Text(value ?? '', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
            onPressed: onEdit,
            tooltip: 'Chỉnh sửa $label',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.blue.shade800,
        ),
      ),
    );
  }

  void _showEditTextDialog(String label, String initialValue, ValueChanged<String> onSave, bool isDark) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('Chỉnh sửa $label', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text('OK'),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // format ngày sinh
  String _formatDob(String? dob) {
  if (dob == null || dob.isEmpty) return '';
  try {
    final dt = DateTime.parse(dob);
    return DateFormat('dd/MM/yyyy').format(dt);
  } catch (_) {
    return dob;
  }
}

  void _showEditGenderDialog(bool isDark) {
    String tempGender = _editGender ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('Chỉnh sửa Giới tính', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: DropdownButtonFormField<String>(
          value: tempGender.isNotEmpty ? tempGender : 'Nam',
          items: ['Nam', 'Nữ', 'Khác'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => tempGender = val ?? 'Nam',
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text('OK'),
            onPressed: () {
              setState(() => _editGender = tempGender);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditAvatarDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('Chỉnh sửa Ảnh hồ sơ', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Center(
          child: CircleAvatar(radius: 48, backgroundImage: NetworkImage(_editAvatarUrl ?? '')),
        ),
        actions: [
          TextButton(
            child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text('OK'),
            onPressed: () {
              setState(() => _editAvatarUrl = 'https://i.pravatar.cc/150?img=5');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(bool isDark) {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Đổi mật khẩu', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Nhập mật khẩu hiện tại và mật khẩu mới của bạn.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu hiện tại',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu hiện tại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu mới',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu mới';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Xác nhận mật khẩu mới',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu mới';
                          }
                          if (value != newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('logged_in_user_id');
                      if (userId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
                          );
                        }
                        setState(() => isLoading = false);
                        return;
                      }

                      try {
                        // Gọi API đổi mật khẩu (bạn cần tạo endpoint này trên backend)
                        final res = await http.put(
                          Uri.parse('http://localhost:4567/api/user/$userId/change-password'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'currentPassword': currentPasswordController.text,
                            'newPassword': newPasswordController.text,
                          }),
                        );
                        if (res.statusCode == 200) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đổi mật khẩu thành công!')),
                            );
                            Navigator.of(context).pop();
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: ${json.decode(res.body)['message']}')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Đổi mật khẩu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
