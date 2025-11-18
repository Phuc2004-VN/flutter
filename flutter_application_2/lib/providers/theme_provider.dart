import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue; // Default primary color
  Color _selectedBackgroundColor = Colors.blue.shade50; // Default background color (light mode canvas color)

  ThemeProvider() {
    _loadThemePreferences();
  }

  bool get isDarkMode => _isDarkMode;
  Color get selectedColor => _selectedColor;
  Color get selectedBackgroundColor => _selectedBackgroundColor;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    // When toggling theme, reset background to default theme background
    _selectedBackgroundColor = _isDarkMode ? Colors.black : Colors.blue.shade50; // Default dark/light backgrounds
    _saveThemePreferences();
    notifyListeners();
  }

  void setThemeColor(Color color) {
    _selectedColor = color;
    _saveThemePreferences();
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _selectedBackgroundColor = color;
    _saveThemePreferences();
    notifyListeners();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final int? colorValue = prefs.getInt('selectedColor');
    if (colorValue != null) {
      _selectedColor = Color(colorValue);
    } else {
      _selectedColor = Colors.blue; // Default primary if not saved
    }
    // Load background color preference
    final int? backgroundColorValue = prefs.getInt('selectedBackgroundColor');
    if (backgroundColorValue != null) {
      _selectedBackgroundColor = Color(backgroundColorValue);
    } else {
       // Set default background based on loaded dark mode preference
       _selectedBackgroundColor = _isDarkMode ? Colors.black : Colors.blue.shade50;
    }
    notifyListeners();
  }

  Future<void> _saveThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('selectedColor', _selectedColor.value);
    // Save background color as int
    await prefs.setInt('selectedBackgroundColor', _selectedBackgroundColor.value);
  }
} 