import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/bill_settings_model.dart';

class BillSettingsRepository {
  final SharedPreferences _prefs;
  static const _key = 'bill_settings';

  BillSettingsRepository(this._prefs);

  Future<void> saveSettings(BillSettings settings) async {
    final jsonStr = jsonEncode(settings.toMap());
    await _prefs.setString(_key, jsonStr);
  }

  BillSettings getSettings() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return BillSettings();
    try {
      final map = jsonDecode(jsonStr);
      return BillSettings.fromMap(map);
    } catch (e) {
      return BillSettings();
    }
  }
}
