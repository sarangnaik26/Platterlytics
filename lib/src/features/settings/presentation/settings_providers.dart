import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(SettingsRepositoryRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}

@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  Future<ThemeMode> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    final modeStr = repo.getThemeMode();
    switch (modeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      default:
        modeStr = 'system';
    }
    await repo.setThemeMode(modeStr);
    state = AsyncValue.data(mode);
  }
}

class CacheSettings {
  final String frequency; // never, week, month, year, custom
  final int customDays;

  CacheSettings({required this.frequency, required this.customDays});

  CacheSettings copyWith({String? frequency, int? customDays}) {
    return CacheSettings(
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
    );
  }
}

@riverpod
class CacheSettingsController extends _$CacheSettingsController {
  @override
  Future<CacheSettings> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return CacheSettings(
      frequency: repo.getAutoCacheFrequency(),
      customDays: repo.getAutoCacheDays(),
    );
  }

  Future<void> updateFrequency(String frequency) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setAutoCacheFrequency(frequency);
    state = AsyncValue.data(state.value!.copyWith(frequency: frequency));
  }

  Future<void> updateCustomDays(int days) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setAutoCacheDays(days);
    state = AsyncValue.data(state.value!.copyWith(customDays: days));
  }
}

@riverpod
class CacheService extends _$CacheService {
  @override
  void build() {}

  Future<void> clearCacheBefore(DateTime date) async {
    // This is a placeholder for actual cache clearing logic.
    // In a real app, this would delete files from temporary directories or specific cache folders.
    // For now, we will just simulate it or clear safe temp directories.

    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        final files = cacheDir.listSync();
        for (var file in files) {
          final stat = await file.stat();
          if (stat.modified.isBefore(date)) {
            try {
              await file.delete(recursive: true);
            } catch (e) {
              // Ignore deletion errors
            }
          }
        }
      }

      // Also potentially clear application support directory if used for detailed logs or temp data
      // be careful not to delete important DBs.
    } catch (e) {
      rethrow;
    }
  }
}
