import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/profile_model.dart';

class ProfileRepository {
  final SharedPreferences _prefs;
  static const _key = 'user_profile';

  ProfileRepository(this._prefs);

  Future<void> saveProfile(UserProfile profile) async {
    final jsonStr = jsonEncode(profile.toMap());
    await _prefs.setString(_key, jsonStr);
  }

  UserProfile getProfile() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return UserProfile();
    try {
      final map = jsonDecode(jsonStr);
      return UserProfile.fromMap(map);
    } catch (e) {
      return UserProfile();
    }
  }
}
