import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _hapticKey = 'haptic_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _animationsKey = 'animations_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;
  bool get isInitialized => _isInitialized;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  Future<void> initializeSettings() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    _hapticEnabled = prefs.getBool(_hapticKey) ?? true;
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _animationsEnabled = prefs.getBool(_animationsKey) ?? true;
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
    await prefs.setBool(_hapticKey, _hapticEnabled);
    await prefs.setBool(_soundKey, _soundEnabled);
    await prefs.setBool(_animationsKey, _animationsEnabled);
  }

  Future<void> toggleTheme() async {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _themeMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleHaptic() async {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _hapticEnabled = !_hapticEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleSound() async {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _soundEnabled = !_soundEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleAnimations() async {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _animationsEnabled = !_animationsEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> triggerHaptic(HapticFeedbackType type) async {
    if (!_hapticEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  Future<void> resetSettings() async {
    _themeMode = ThemeMode.system;
    _hapticEnabled = true;
    _soundEnabled = true;
    _animationsEnabled = true;
    await _saveSettings();
    notifyListeners();
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
}
