import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:4567/api'; //URL tùy theo server của bạn

  static Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Xử lý response thành công
      } else {
        throw Exception('Failed to send reset password email');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'currentPassword': currentPassword, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        // Xử lý response thành công (ví dụ: hiển thị thông báo thành công)
        debugPrint('Đổi mật khẩu thành công');
      } else {
        // Xử lý lỗi dựa trên mã trạng thái
        final errorBody = json.decode(response.body);
        throw Exception('Failed to change password: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }
}

/*
file này dùng để xử lý các yêu cầu liên quan đến đăng nhập, đăng ký, quên mật khẩu, đổi mật khẩu, ...
ví dụ như gửi email để đặt lại mật khẩu, đổi mật khẩu, ...
*/