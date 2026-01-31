// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencySymbolHash() => r'5bfee4fdc3115dffcf1dd0578bc810aa107f8765';

/// See also [currencySymbol].
@ProviderFor(currencySymbol)
final currencySymbolProvider = AutoDisposeProvider<String>.internal(
  currencySymbol,
  name: r'currencySymbolProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencySymbolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencySymbolRef = AutoDisposeProviderRef<String>;
String _$billSettingsControllerHash() =>
    r'5210c8095d958e13279cb144037c00f7309e44f8';

/// See also [BillSettingsController].
@ProviderFor(BillSettingsController)
final billSettingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BillSettingsController,
      BillSettings
    >.internal(
      BillSettingsController.new,
      name: r'billSettingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$billSettingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BillSettingsController = AutoDisposeAsyncNotifier<BillSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
