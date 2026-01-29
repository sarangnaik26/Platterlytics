import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/data/bill_settings_repository.dart';
import '../../settings/domain/bill_settings_model.dart';
import 'settings_providers.dart'; // import to reuse settingsRepositoryProvider or creating new one

part 'bill_settings_provider.g.dart';

@riverpod
class BillSettingsController extends _$BillSettingsController {
  @override
  Future<BillSettings> build() async {
    final repo = await _getRepository();
    return repo.getSettings();
  }

  Future<BillSettingsRepository> _getRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return BillSettingsRepository(prefs);
  }

  Future<void> updateSettings(BillSettings settings) async {
    final repo = await _getRepository();
    await repo.saveSettings(settings);
    state = AsyncValue.data(settings);
  }
}
