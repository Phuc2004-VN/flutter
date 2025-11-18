// import 'package:flutter/material.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   bool _isEditing = false;
//   final _nameController = TextEditingController(text: '');
//   final _dobController = TextEditingController(text: '');
//   String _gender = 'Nam';
//   final _emailController = TextEditingController(text: '');
//   final _phoneController = TextEditingController(text: '');

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade800,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.white)),
//         actions: [
//           !_isEditing
//               ? IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.white),
//                   onPressed: () => setState(() => _isEditing = true),
//                 )
//               : Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.check, color: Colors.white),
//                       onPressed: () {
//                         setState(() => _isEditing = false);
//                         // TODO: Lưu thông tin vào database
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: () => setState(() => _isEditing = false),
//                     ),
//                   ],
//                 ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(32),
//         child: Center(
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 500),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey.shade900 : Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 48,
//                       backgroundColor: Colors.blue.shade100,
//                       backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=3'),
//                     ),
//                     if (_isEditing)
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: CircleAvatar(
//                           radius: 18,
//                           backgroundColor: Colors.blue.shade600,
//                           child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 _buildSectionTitle('Thông tin cơ bản', isDark),
//                 const SizedBox(height: 16),
//                 _buildTextField('Họ và tên', _nameController, enabled: _isEditing, isDark: isDark),
//                 const SizedBox(height: 16),
//                 _buildTextField('Ngày sinh', _dobController, enabled: _isEditing, isDark: isDark),
//                 const SizedBox(height: 16),
//                 _isEditing
//                     ? _buildGenderDropdown()
//                     : _buildReadOnlyField('Giới tính', _gender, isDark),
//                 const SizedBox(height: 32),
//                 _buildSectionTitle('Thông tin liên hệ', isDark),
//                 const SizedBox(height: 16),
//                 _buildTextField('Email', _emailController, enabled: _isEditing, isDark: isDark),
//                 const SizedBox(height: 16),
//                 _buildTextField('Số điện thoại', _phoneController, enabled: _isEditing, isDark: isDark),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, bool isDark) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: isDark ? Colors.white : Colors.blue.shade800,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {bool enabled = false, required bool isDark}) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
//         filled: true,
//         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyField(String label, String value, bool isDark) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
//       ),
//       child: Text('$label: $value', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
//     );
//   }

//   Widget _buildGenderDropdown() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return DropdownButtonFormField<String>(
//       value: _gender,
//       items: ['Nam', 'Nữ', 'Khác'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
//       onChanged: (val) => setState(() => _gender = val ?? 'Nam'),
//       decoration: InputDecoration(
//         labelText: 'Giới tính',
//         labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade800),
//         filled: true,
//         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//         ),
//       ),
//       dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
// } 