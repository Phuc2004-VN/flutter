import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  final bool isDark;

  const FooterSection({Key? key, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 23, 52, 66), // Use header's dark mode color for dark mode, keep user's color for light mode
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Column 1: Company Info
              const Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HỆ THỐNG SẮP XẾP LỊCH TRÌNH',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Ứng dụng giúp bạn quản lý lịch trình và công việc hiệu quả.', // Placeholder description
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Column 2: Liên hệ / Hỗ trợ
              Expanded(
                 flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Liên hệ / Hỗ trợ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: support@yourdomain.com',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                    ),
                     const SizedBox(height: 4),
                     Text(
                      'Hotline: 0123 456 789',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement Hướng dẫn sử dụng link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('[Hướng dẫn sử dụng]', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Trung tâm trợ giúp link
                      },
                       style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('[Trung tâm trợ giúp]', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Gửi phản hồi link
                      },
                       style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('[Gửi phản hồi]', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
               const SizedBox(width: 24),

              // Column 3: Liên kết nhanh
               Expanded(
                 flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liên kết nhanh',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                     const SizedBox(height: 8),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Trang chủ link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Trang chủ', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Lịch link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Lịch', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Thống kê link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Thống kê', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Cài đặt link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Cài đặt', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
               const SizedBox(width: 24),

              // Column 4: Policies / Version
               Expanded(
                 flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông báo pháp lý / Chính sách',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                     const SizedBox(height: 8),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Chính sách bảo mật link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Chính sách bảo mật', style: TextStyle(fontSize: 12)),
                    ),
                     TextButton(
                      onPressed: () {
                        // TODO: Implement Điều khoản sử dụng link
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                      child: const Text('Điều khoản sử dụng', style: TextStyle(fontSize: 12)),
                    ),
                     const SizedBox(height: 16), // Space before version
                     Text(
                      'Phiên bản hệ thống:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.white),
                    ),
                     const SizedBox(height: 8),
                      Text(
                      'Cập nhật lần cuối: 01/06/2025', // You can make this dynamic if needed
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32), // Space before copyright
          // Bottom Copyright Section
          Container(
             alignment: Alignment.center,
             padding: const EdgeInsets.symmetric(vertical: 16.0),
             decoration: BoxDecoration(
               border: Border(top: BorderSide(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade700, width: 1.0)),
             ), // Add a top border
             child: Text(
              '© 2025 Hệ thống sắp xếp lịch trình. Đã đăng ký bản quyền.',
              textAlign: TextAlign.center,
               style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.white),
             ),
           ),
        ],
      ),
    );
  }
} 