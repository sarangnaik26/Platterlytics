import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/data/bill_settings_repository.dart';
import '../../settings/domain/bill_settings_model.dart';
// import to reuse settingsRepositoryProvider or creating new one

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

@riverpod
String formatCurrency(Ref ref, double amount) {
  final settingsAsync = ref.watch(billSettingsControllerProvider);
  return settingsAsync.when(
    data: (s) {
      final formatted = amount.toStringAsFixed(2);
      return s.currencyAtEnd
          ? "$formatted ${s.currencySymbol}"
          : "${s.currencySymbol} $formatted";
    },
    loading: () => "₹ ${amount.toStringAsFixed(2)}",
    error: (e, s) => "₹ ${amount.toStringAsFixed(2)}",
  );
}

@riverpod
String currencySymbol(Ref ref) {
  final settings = ref.watch(billSettingsControllerProvider).valueOrNull;
  return settings?.currencySymbol ?? "₹";
}
