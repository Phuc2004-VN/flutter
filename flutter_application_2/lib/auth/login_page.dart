// lib/auth/login_page.dart (Đã chỉnh sửa)

import 'package:flutter/material.dart';
import 'register_page.dart';
import 'package:flutter_application_2/services/api_service.dart'; // 👈 Thay đổi import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/models/schedule_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiService(); // 👈 Khởi tạo ApiService

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 👈 Gọi API Service
      final responseData = await _apiService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (responseData != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
          
          // Lấy thông tin người dùng và token
          final int userId = responseData['id'];
          final String username = responseData['username'];
          final String email = responseData['email'];
          final String token = responseData['token']; // 👈 QUAN TRỌNG: Lấy Token
          
          // lưu thông tin người dùng và token vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('logged_in_user_id', userId);
          await prefs.setString('logged_in_username', username);
          await prefs.setString('logged_in_user_email', email);
          await prefs.setString('logged_in_user_avatar', ''); // Avatar không được trả về trong response login
          await prefs.setString('auth_token', token); // 👈 LƯU JWT VÀO BỘ NHỚ CỤC BỘ

          // Đồng bộ lịch từ backend ngay sau khi đăng nhập
          if (!mounted) return;
          await Provider.of<ScheduleProvider>(context, listen: false).refreshFromBackend();

          // Chuyển hướng đến trang chính
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')), // Chuyển đổi lỗi thành String
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
  
  // Giữ nguyên widget build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/6263040.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25), // Padding inside the overlay box
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Dark semi-transparent background
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Make the column take minimum space
              children: [
                  // Logo or App Name
                  const Icon(
                    Icons.schedule,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hệ thống sắp xếp lịch trình',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                
                // Form đăng nhập
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                              mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                                const SizedBox(height: 20),
                          
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Email hoặc tên tài khoản',
                              prefixIcon: const Icon(Icons.person, color: Colors.blue),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập email hoặc tên tài khoản';
                                    }
                                    return null;
                                  },
                                ),
                          
                                const SizedBox(height: 15),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    return null;
                                  },
                          ),
                          
                                const SizedBox(height: 15),
                                
                                // Remember me and Forgot password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Remember Me
                                    Row(
                                      mainAxisSize: MainAxisSize.max, // Đổi từ min sang max để căn chỉnh
                                      children: [
                                        Checkbox(value: false, onChanged: (value) { /* TODO: Implement remember me */ },), // Placeholder checkbox
                                        const Text(
                                          'Nhớ mật khẩu',
                                style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Forgot password
                                    TextButton(
                                      onPressed: () { /* TODO: Implement forgot password logic */ },
                                      child: const Text(
                                        'Quên mật khẩu?',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Login button
                        SizedBox(
                          width: double.infinity,
                            height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                : const Text(
                                    'ĐĂNG NHẬP',
                                    style: TextStyle(
                                        fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Text(
                                'Chưa có tài khoản?',
                                      style: TextStyle(
                                        color: Colors.black87,
                                      ),
                              ),
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: const Text(
                                  'Đăng ký ngay',
                            style: TextStyle(
                              color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                          ),
                        ],
                            ),
                      ),
                    ),
                  ),
                ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}