// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Thay thế bằng URL và Port của server Node.js của bạn
  final String baseUrl = 'http://localhost:4567/api'; 

  // Hàm Đăng ký người dùng
  Future<bool> registerUser(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Đăng ký thành công
      return true;
    } else if (response.statusCode == 400) {
      // Ví dụ: Username/email đã tồn tại
      return false;
    } else {
      // Xử lý lỗi server khác
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Hàm Đăng nhập người dùng (QUAN TRỌNG: Trả về Token và User Data)
  Future<Map<String, dynamic>?> loginUser(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': identifier, // Backend nhận email hoặc username tại trường này
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Đăng nhập thành công, nhận token và user data
      final data = jsonDecode(response.body);
      
      // Phải trả về cả token và thông tin người dùng
      return {
        'id': data['user']['id'],
        'username': data['user']['username'],
        'email': data['user']['email'],
        'token': data['token'], // Lấy và trả về JWT
      };
    } else if (response.statusCode == 400) {
      // Email hoặc mật khẩu không đúng
      return null;
    } else {
      // Xử lý lỗi server khác
      throw Exception('Failed to login: ${response.body}');
    }
  }
}