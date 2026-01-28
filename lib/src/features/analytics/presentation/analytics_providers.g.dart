// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyStatsHash() => r'9eb6e8d29d20e46f784030199211839a7c461d86';

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

/// See also [dailyStats].
@ProviderFor(dailyStats)
const dailyStatsProvider = DailyStatsFamily();

/// See also [dailyStats].
class DailyStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [dailyStats].
  const DailyStatsFamily();

  /// See also [dailyStats].
  DailyStatsProvider call(String date) {
    return DailyStatsProvider(date);
  }

  @override
  DailyStatsProvider getProviderOverride(
    covariant DailyStatsProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyStatsProvider';
}

/// See also [dailyStats].
class DailyStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [dailyStats].
  DailyStatsProvider(String date)
    : this._internal(
        (ref) => dailyStats(ref as DailyStatsRef, date),
        from: dailyStatsProvider,
        name: r'dailyStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dailyStatsHash,
        dependencies: DailyStatsFamily._dependencies,
        allTransitiveDependencies: DailyStatsFamily._allTransitiveDependencies,
        date: date,
      );

  DailyStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(DailyStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyStatsProvider._internal(
        (ref) => create(ref as DailyStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _DailyStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyStatsProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _DailyStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with DailyStatsRef {
  _DailyStatsProviderElement(super.provider);

  @override
  String get date => (origin as DailyStatsProvider).date;
}

String _$rangeStatsHash() => r'b52e58df424ea9dda2b903133fb8d950ea9bea69';

/// See also [rangeStats].
@ProviderFor(rangeStats)
const rangeStatsProvider = RangeStatsFamily();

/// See also [rangeStats].
class RangeStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [rangeStats].
  const RangeStatsFamily();

  /// See also [rangeStats].
  RangeStatsProvider call(String startDate, String endDate) {
    return RangeStatsProvider(startDate, endDate);
  }

  @override
  RangeStatsProvider getProviderOverride(
    covariant RangeStatsProvider provider,
  ) {
    return call(provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rangeStatsProvider';
}

/// See also [rangeStats].
class RangeStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [rangeStats].
  RangeStatsProvider(String startDate, String endDate)
    : this._internal(
        (ref) => rangeStats(ref as RangeStatsRef, startDate, endDate),
        from: rangeStatsProvider,
        name: r'rangeStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rangeStatsHash,
        dependencies: RangeStatsFamily._dependencies,
        allTransitiveDependencies: RangeStatsFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  RangeStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String startDate;
  final String endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(RangeStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RangeStatsProvider._internal(
        (ref) => create(ref as RangeStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _RangeStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RangeStatsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RangeStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `startDate` of this provider.
  String get startDate;

  /// The parameter `endDate` of this provider.
  String get endDate;
}

class _RangeStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with RangeStatsRef {
  _RangeStatsProviderElement(super.provider);

  @override
  String get startDate => (origin as RangeStatsProvider).startDate;
  @override
  String get endDate => (origin as RangeStatsProvider).endDate;
}

String _$itemDailyStatsHash() => r'2a41527a15e8c55edde9061ab441ef1bdeded96a';

/// See also [itemDailyStats].
@ProviderFor(itemDailyStats)
const itemDailyStatsProvider = ItemDailyStatsFamily();

/// See also [itemDailyStats].
class ItemDailyStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [itemDailyStats].
  const ItemDailyStatsFamily();

  /// See also [itemDailyStats].
  ItemDailyStatsProvider call(int menuId, String date) {
    return ItemDailyStatsProvider(menuId, date);
  }

  @override
  ItemDailyStatsProvider getProviderOverride(
    covariant ItemDailyStatsProvider provider,
  ) {
    return call(provider.menuId, provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemDailyStatsProvider';
}

/// See also [itemDailyStats].
class ItemDailyStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [itemDailyStats].
  ItemDailyStatsProvider(int menuId, String date)
    : this._internal(
        (ref) => itemDailyStats(ref as ItemDailyStatsRef, menuId, date),
        from: itemDailyStatsProvider,
        name: r'itemDailyStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemDailyStatsHash,
        dependencies: ItemDailyStatsFamily._dependencies,
        allTransitiveDependencies:
            ItemDailyStatsFamily._allTransitiveDependencies,
        menuId: menuId,
        date: date,
      );

  ItemDailyStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.menuId,
    required this.date,
  }) : super.internal();

  final int menuId;
  final String date;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ItemDailyStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemDailyStatsProvider._internal(
        (ref) => create(ref as ItemDailyStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        menuId: menuId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ItemDailyStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemDailyStatsProvider &&
        other.menuId == menuId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, menuId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemDailyStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `menuId` of this provider.
  int get menuId;

  /// The parameter `date` of this provider.
  String get date;
}

class _ItemDailyStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ItemDailyStatsRef {
  _ItemDailyStatsProviderElement(super.provider);

  @override
  int get menuId => (origin as ItemDailyStatsProvider).menuId;
  @override
  String get date => (origin as ItemDailyStatsProvider).date;
}

String _$itemRangeStatsHash() => r'4d15c7234947d9714993e63839a77435646bf649';

/// See also [itemRangeStats].
@ProviderFor(itemRangeStats)
const itemRangeStatsProvider = ItemRangeStatsFamily();

/// See also [itemRangeStats].
class ItemRangeStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [itemRangeStats].
  const ItemRangeStatsFamily();

  /// See also [itemRangeStats].
  ItemRangeStatsProvider call(int menuId, String startDate, String endDate) {
    return ItemRangeStatsProvider(menuId, startDate, endDate);
  }

  @override
  ItemRangeStatsProvider getProviderOverride(
    covariant ItemRangeStatsProvider provider,
  ) {
    return call(provider.menuId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemRangeStatsProvider';
}

/// See also [itemRangeStats].
class ItemRangeStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [itemRangeStats].
  ItemRangeStatsProvider(int menuId, String startDate, String endDate)
    : this._internal(
        (ref) => itemRangeStats(
          ref as ItemRangeStatsRef,
          menuId,
          startDate,
          endDate,
        ),
        from: itemRangeStatsProvider,
        name: r'itemRangeStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemRangeStatsHash,
        dependencies: ItemRangeStatsFamily._dependencies,
        allTransitiveDependencies:
            ItemRangeStatsFamily._allTransitiveDependencies,
        menuId: menuId,
        startDate: startDate,
        endDate: endDate,
      );

  ItemRangeStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.menuId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int menuId;
  final String startDate;
  final String endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ItemRangeStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemRangeStatsProvider._internal(
        (ref) => create(ref as ItemRangeStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        menuId: menuId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ItemRangeStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemRangeStatsProvider &&
        other.menuId == menuId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, menuId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemRangeStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `menuId` of this provider.
  int get menuId;

  /// The parameter `startDate` of this provider.
  String get startDate;

  /// The parameter `endDate` of this provider.
  String get endDate;
}

class _ItemRangeStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ItemRangeStatsRef {
  _ItemRangeStatsProviderElement(super.provider);

  @override
  int get menuId => (origin as ItemRangeStatsProvider).menuId;
  @override
  String get startDate => (origin as ItemRangeStatsProvider).startDate;
  @override
  String get endDate => (origin as ItemRangeStatsProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
