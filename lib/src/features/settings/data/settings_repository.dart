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

  static const _weekdayAnalysisWindowKey = 'weekday_analysis_window';

  static const _dateFormatKey = 'date_format';

  Future<void> setAutoCacheDays(int days) async {
    await _prefs.setInt(_autoCacheDaysKey, days);
  }

  int getAutoCacheDays() {
    return _prefs.getInt(_autoCacheDaysKey) ?? 7;
  }

  Future<void> setWeekdayAnalysisWindow(int weeks) async {
    await _prefs.setInt(_weekdayAnalysisWindowKey, weeks);
  }

  int getWeekdayAnalysisWindow() {
    return _prefs.getInt(_weekdayAnalysisWindowKey) ?? 4;
  }

  Future<void> setDateFormat(String format) async {
    await _prefs.setString(_dateFormatKey, format);
  }

  String getDateFormat() {
    return _prefs.getString(_dateFormatKey) ?? 'dd/MM/yyyy';
  }

  static const _autoDeleteBillsFreqKey = 'auto_delete_bills_frequency';
  static const _autoDeleteBillsMonthsKey = 'auto_delete_bills_months';

  Future<void> setAutoDeleteBillsFrequency(String frequency) async {
    await _prefs.setString(_autoDeleteBillsFreqKey, frequency);
  }

  String getAutoDeleteBillsFrequency() {
    return _prefs.getString(_autoDeleteBillsFreqKey) ?? 'never';
  }

  Future<void> setAutoDeleteBillsMonths(int months) async {
    await _prefs.setInt(_autoDeleteBillsMonthsKey, months);
  }

  int getAutoDeleteBillsMonths() {
    return _prefs.getInt(_autoDeleteBillsMonthsKey) ?? 1;
  }
}
