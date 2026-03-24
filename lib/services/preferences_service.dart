import 'package:shared_preferences/shared_preferences.dart';

/// Manages user preferences stored via SharedPreferences.
///
/// Wraps all preference keys in typed getters/setters to
/// avoid stringly-typed access throughout the codebase.
class PreferencesService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontSize = 'font_size';
  static const _keyDifficulty = 'difficulty';
  static const _keyHintDelay = 'hint_delay_seconds';
  static const _keyTimerEnabled = 'timer_enabled';
  static const _keyLastMissionPlayed = 'last_mission_played';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyDisplayName = 'display_name';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Theme: 'light', 'dark', or 'system'
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String value) =>
      _prefs.setString(_keyThemeMode, value);

  // Font size multiplier (0.8 – 1.4)
  double get fontSize => _prefs.getDouble(_keyFontSize) ?? 1.0;
  Future<bool> setFontSize(double value) =>
      _prefs.setDouble(_keyFontSize, value);

  // Default difficulty for new missions
  String get difficulty => _prefs.getString(_keyDifficulty) ?? 'medium';
  Future<bool> setDifficulty(String value) =>
      _prefs.setString(_keyDifficulty, value);

  // Seconds before the AI hint system activates
  int get hintDelaySeconds => _prefs.getInt(_keyHintDelay) ?? 60;
  Future<bool> setHintDelaySeconds(int value) =>
      _prefs.setInt(_keyHintDelay, value);

  // Whether the countdown timer is shown during puzzles
  bool get timerEnabled => _prefs.getBool(_keyTimerEnabled) ?? true;
  Future<bool> setTimerEnabled(bool value) =>
      _prefs.setBool(_keyTimerEnabled, value);

  // ID of the last mission the player opened
  int get lastMissionPlayed => _prefs.getInt(_keyLastMissionPlayed) ?? -1;
  Future<bool> setLastMissionPlayed(int value) =>
      _prefs.setInt(_keyLastMissionPlayed, value);

  // Sound effects toggle
  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<bool> setSoundEnabled(bool value) =>
      _prefs.setBool(_keySoundEnabled, value);

  // Display name for the player
  String get displayName => _prefs.getString(_keyDisplayName) ?? 'Player';
  Future<bool> setDisplayName(String value) =>
      _prefs.setString(_keyDisplayName, value);
}
