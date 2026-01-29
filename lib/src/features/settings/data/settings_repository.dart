import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _themeKey = 'theme_mode';
  static const _autoCacheFreqKey = 'auto_cache_frequency';
  static const _autoCacheDaysKey = 'auto_cache_days';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setAutoCacheFrequency(String frequency) async {
    await _prefs.setString(_autoCacheFreqKey, frequency);
  }

  String getAutoCacheFrequency() {
    return _prefs.getString(_autoCacheFreqKey) ?? 'never';
  }

  Future<void> setAutoCacheDays(int days) async {
    await _prefs.setInt(_autoCacheDaysKey, days);
  }

  int getAutoCacheDays() {
    return _prefs.getInt(_autoCacheDaysKey) ?? 7;
  }
}
