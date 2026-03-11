import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode;

  /// Initialize theme from saved preference
  Future<void> initTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedTheme = _prefs.getString(_themeKey);
      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (e) {
      // Error initializing theme
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      await _prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
      // Error saving theme preference
    }
    notifyListeners();
  }

  ThemeData getThemeData(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}
