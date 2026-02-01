// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'9b87adf667d44c51ab91f1d3d35e851b915d42ed';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = FutureProvider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = FutureProviderRef<SettingsRepository>;
String _$themeModeControllerHash() =>
    r'13e701d26dec767860e97dea0c38a17369dbc263';

/// See also [ThemeModeController].
@ProviderFor(ThemeModeController)
final themeModeControllerProvider =
    AutoDisposeAsyncNotifierProvider<ThemeModeController, ThemeMode>.internal(
      ThemeModeController.new,
      name: r'themeModeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeModeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeModeController = AutoDisposeAsyncNotifier<ThemeMode>;
String _$cacheSettingsControllerHash() =>
    r'cb9b10648c3f6973c5cf845f7b2f493f4115db8e';

/// See also [CacheSettingsController].
@ProviderFor(CacheSettingsController)
final cacheSettingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      CacheSettingsController,
      CacheSettings
    >.internal(
      CacheSettingsController.new,
      name: r'cacheSettingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheSettingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CacheSettingsController = AutoDisposeAsyncNotifier<CacheSettings>;
String _$cacheServiceHash() => r'6b7185387a8b71c10104d57cddaf812d2665c80a';

/// See also [CacheService].
@ProviderFor(CacheService)
final cacheServiceProvider =
    AutoDisposeNotifierProvider<CacheService, void>.internal(
      CacheService.new,
      name: r'cacheServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CacheService = AutoDisposeNotifier<void>;
String _$analyticsSettingsControllerHash() =>
    r'88be7969434f3515b25fc3319f131f2693ba922b';

/// See also [AnalyticsSettingsController].
@ProviderFor(AnalyticsSettingsController)
final analyticsSettingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<AnalyticsSettingsController, int>.internal(
      AnalyticsSettingsController.new,
      name: r'analyticsSettingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsSettingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalyticsSettingsController = AutoDisposeAsyncNotifier<int>;
String _$dateFormatControllerHash() =>
    r'2941d1f3388c007e6654c8bdffba2a1ec6a54c5c';

/// See also [DateFormatController].
@ProviderFor(DateFormatController)
final dateFormatControllerProvider =
    AutoDisposeAsyncNotifierProvider<DateFormatController, String>.internal(
      DateFormatController.new,
      name: r'dateFormatControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dateFormatControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DateFormatController = AutoDisposeAsyncNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
