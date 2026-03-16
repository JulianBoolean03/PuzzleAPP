import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

/// Manages the app-wide theme mode and font scale.
///
/// Reads initial values from [PreferencesService] and persists
/// changes back, so theme preference survives app restarts.
class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  late ThemeMode _themeMode;
  late double _fontScale;

  ThemeProvider(this._prefs) {
    _themeMode = _parseThemeMode(_prefs.themeMode);
    _fontScale = _prefs.fontSize;
  }

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.4);
    await _prefs.setFontSize(_fontScale);
    notifyListeners();
  }

  /// Cycles through light → dark → system → light.
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
