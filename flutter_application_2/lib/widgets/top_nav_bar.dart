import 'package:flutter/material.dart';
import 'package:flutter_application_2/widgets/workspace_selector.dart';
import 'package:flutter_application_2/screens/setting_screen.dart';

class TopNavBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddWorkspacePressed;
  final VoidCallback onLoginPressed;
  final VoidCallback onLogout;
  final String loggedInUsername;
  final String loggedInUserEmail;
  final String loggedInUserAvatar;

  const TopNavBar({
    Key? key,
    required this.isDark,
    required this.onAddWorkspacePressed,
    required this.onLoginPressed,
    required this.loggedInUsername,
    required this.loggedInUserEmail,
    required this.loggedInUserAvatar,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.blueGrey.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WorkspaceSelector(),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onAddWorkspacePressed,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Góc phải: chỉ 1 trong 2
          if (loggedInUsername.isEmpty)
            ElevatedButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            )
          else
            PopupMenuButton<int>(
              offset: const Offset(0, 60),
              color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tooltip: 'Thông tin người dùng',
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 32,
                        backgroundImage: (loggedInUserAvatar.isNotEmpty)
                            ? NetworkImage(loggedInUserAvatar)
                            : null,
                        child: loggedInUserAvatar.isEmpty
                            ? Icon(Icons.person_outline, color: Colors.blue.shade700, size: 36)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loggedInUsername,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loggedInUserEmail,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: isDark ? Colors.white24 : Colors.grey.shade300, thickness: 1),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: isDark ? Colors.blue[200] : Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Thông tin cá nhân'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red[300]),
                      const SizedBox(width: 8),
                      const Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingScreen(selectedTab: 2, profileTab: 1),
                    ),
                  );
                } else if (value == 2) {
                  onLogout();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      backgroundImage: (loggedInUserAvatar.isNotEmpty)
                          ? NetworkImage(loggedInUserAvatar)
                          : null,
                      child: loggedInUserAvatar.isEmpty
                          ? Icon(Icons.person_outline, color: Colors.blue.shade700, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loggedInUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}