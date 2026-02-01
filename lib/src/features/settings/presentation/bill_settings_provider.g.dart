// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$formatCurrencyHash() => r'07623313050f1908abd999eb9885bcda3feea32c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [formatCurrency].
@ProviderFor(formatCurrency)
const formatCurrencyProvider = FormatCurrencyFamily();

/// See also [formatCurrency].
class FormatCurrencyFamily extends Family<String> {
  /// See also [formatCurrency].
  const FormatCurrencyFamily();

  /// See also [formatCurrency].
  FormatCurrencyProvider call(double amount) {
    return FormatCurrencyProvider(amount);
  }

  @override
  FormatCurrencyProvider getProviderOverride(
    covariant FormatCurrencyProvider provider,
  ) {
    return call(provider.amount);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formatCurrencyProvider';
}

/// See also [formatCurrency].
class FormatCurrencyProvider extends AutoDisposeProvider<String> {
  /// See also [formatCurrency].
  FormatCurrencyProvider(double amount)
    : this._internal(
        (ref) => formatCurrency(ref as FormatCurrencyRef, amount),
        from: formatCurrencyProvider,
        name: r'formatCurrencyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$formatCurrencyHash,
        dependencies: FormatCurrencyFamily._dependencies,
        allTransitiveDependencies:
            FormatCurrencyFamily._allTransitiveDependencies,
        amount: amount,
      );

  FormatCurrencyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.amount,
  }) : super.internal();

  final double amount;

  @override
  Override overrideWith(String Function(FormatCurrencyRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FormatCurrencyProvider._internal(
        (ref) => create(ref as FormatCurrencyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        amount: amount,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormatCurrencyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormatCurrencyProvider && other.amount == amount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, amount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FormatCurrencyRef on AutoDisposeProviderRef<String> {
  /// The parameter `amount` of this provider.
  double get amount;
}

class _FormatCurrencyProviderElement extends AutoDisposeProviderElement<String>
    with FormatCurrencyRef {
  _FormatCurrencyProviderElement(super.provider);

  @override
  double get amount => (origin as FormatCurrencyProvider).amount;
}

String _$currencySymbolHash() => r'117f8c092875d2814332c74b3925fa99bb27bc92';

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
