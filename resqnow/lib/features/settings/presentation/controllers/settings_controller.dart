import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  late SharedPreferences _prefs;

  // Theme settings - Now synced with ThemeManager
  String _textSize = 'normal';

  // Notification settings
  bool _notificationsEnabled = true;
  bool _emergencyAlertsEnabled = true;

  // Getters
  String get textSize => _textSize;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emergencyAlertsEnabled => _emergencyAlertsEnabled;

  // Keys for SharedPreferences
  static const String _textSizeKey = 'text_size';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _emergencyAlertsKey = 'emergency_alerts_enabled';

  /// Initialize SharedPreferences and load saved settings
  Future<void> loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _textSize = _prefs.getString(_textSizeKey) ?? 'normal';
      _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
      _emergencyAlertsEnabled = _prefs.getBool(_emergencyAlertsKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Save text size preference
  Future<void> saveTextSizePreference(String size) async {
    try {
      _textSize = size;
      await _prefs.setString(_textSizeKey, size);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving text size preference: $e');
    }
  }

  /// Save notifications preference
  Future<void> saveNotificationsPreference(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      await _prefs.setBool(_notificationsKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notifications preference: $e');
    }
  }

  /// Save emergency alerts preference
  Future<void> saveEmergencyAlertsPreference(bool enabled) async {
    try {
      _emergencyAlertsEnabled = enabled;
      await _prefs.setBool(_emergencyAlertsKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving emergency alerts preference: $e');
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      _textSize = 'normal';
      _notificationsEnabled = true;
      _emergencyAlertsEnabled = true;

      await _prefs.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}
