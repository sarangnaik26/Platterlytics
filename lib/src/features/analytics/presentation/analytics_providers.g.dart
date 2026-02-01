// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyStatsHash() => r'9f0b5fb63e1df1ca1cd372930c251b1e8e33d6a2';

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

String _$rangeStatsHash() => r'1900b8895f893019bb8f40f47b0f17bae4f12e78';

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

String _$itemDailyStatsHash() => r'e24a0967bd74b5ddf5127ff0b3790d56ab7578a4';

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

String _$itemRangeStatsHash() => r'18280c0a2ae1c1eb2d324d1ef556bd350030aeb1';

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

String _$weekdayStatsHash() => r'0203959c7af5a6061208ffa1e21053d85a990a36';

/// See also [weekdayStats].
@ProviderFor(weekdayStats)
const weekdayStatsProvider = WeekdayStatsFamily();

/// See also [weekdayStats].
class WeekdayStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [weekdayStats].
  const WeekdayStatsFamily();

  /// See also [weekdayStats].
  WeekdayStatsProvider call(int weeksBack, int weekday) {
    return WeekdayStatsProvider(weeksBack, weekday);
  }

  @override
  WeekdayStatsProvider getProviderOverride(
    covariant WeekdayStatsProvider provider,
  ) {
    return call(provider.weeksBack, provider.weekday);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekdayStatsProvider';
}

/// See also [weekdayStats].
class WeekdayStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [weekdayStats].
  WeekdayStatsProvider(int weeksBack, int weekday)
    : this._internal(
        (ref) => weekdayStats(ref as WeekdayStatsRef, weeksBack, weekday),
        from: weekdayStatsProvider,
        name: r'weekdayStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekdayStatsHash,
        dependencies: WeekdayStatsFamily._dependencies,
        allTransitiveDependencies:
            WeekdayStatsFamily._allTransitiveDependencies,
        weeksBack: weeksBack,
        weekday: weekday,
      );

  WeekdayStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weeksBack,
    required this.weekday,
  }) : super.internal();

  final int weeksBack;
  final int weekday;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(WeekdayStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekdayStatsProvider._internal(
        (ref) => create(ref as WeekdayStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weeksBack: weeksBack,
        weekday: weekday,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _WeekdayStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekdayStatsProvider &&
        other.weeksBack == weeksBack &&
        other.weekday == weekday;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weeksBack.hashCode);
    hash = _SystemHash.combine(hash, weekday.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekdayStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `weeksBack` of this provider.
  int get weeksBack;

  /// The parameter `weekday` of this provider.
  int get weekday;
}

class _WeekdayStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with WeekdayStatsRef {
  _WeekdayStatsProviderElement(super.provider);

  @override
  int get weeksBack => (origin as WeekdayStatsProvider).weeksBack;
  @override
  int get weekday => (origin as WeekdayStatsProvider).weekday;
}

String _$itemWeekdayStatsHash() => r'0dc8d0e46a9e6497c3c518751b65cf5eab811cef';

/// See also [itemWeekdayStats].
@ProviderFor(itemWeekdayStats)
const itemWeekdayStatsProvider = ItemWeekdayStatsFamily();

/// See also [itemWeekdayStats].
class ItemWeekdayStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [itemWeekdayStats].
  const ItemWeekdayStatsFamily();

  /// See also [itemWeekdayStats].
  ItemWeekdayStatsProvider call(int menuId, int weeksBack, int weekday) {
    return ItemWeekdayStatsProvider(menuId, weeksBack, weekday);
  }

  @override
  ItemWeekdayStatsProvider getProviderOverride(
    covariant ItemWeekdayStatsProvider provider,
  ) {
    return call(provider.menuId, provider.weeksBack, provider.weekday);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemWeekdayStatsProvider';
}

/// See also [itemWeekdayStats].
class ItemWeekdayStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [itemWeekdayStats].
  ItemWeekdayStatsProvider(int menuId, int weeksBack, int weekday)
    : this._internal(
        (ref) => itemWeekdayStats(
          ref as ItemWeekdayStatsRef,
          menuId,
          weeksBack,
          weekday,
        ),
        from: itemWeekdayStatsProvider,
        name: r'itemWeekdayStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemWeekdayStatsHash,
        dependencies: ItemWeekdayStatsFamily._dependencies,
        allTransitiveDependencies:
            ItemWeekdayStatsFamily._allTransitiveDependencies,
        menuId: menuId,
        weeksBack: weeksBack,
        weekday: weekday,
      );

  ItemWeekdayStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.menuId,
    required this.weeksBack,
    required this.weekday,
  }) : super.internal();

  final int menuId;
  final int weeksBack;
  final int weekday;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ItemWeekdayStatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemWeekdayStatsProvider._internal(
        (ref) => create(ref as ItemWeekdayStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        menuId: menuId,
        weeksBack: weeksBack,
        weekday: weekday,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ItemWeekdayStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemWeekdayStatsProvider &&
        other.menuId == menuId &&
        other.weeksBack == weeksBack &&
        other.weekday == weekday;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, menuId.hashCode);
    hash = _SystemHash.combine(hash, weeksBack.hashCode);
    hash = _SystemHash.combine(hash, weekday.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemWeekdayStatsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `menuId` of this provider.
  int get menuId;

  /// The parameter `weeksBack` of this provider.
  int get weeksBack;

  /// The parameter `weekday` of this provider.
  int get weekday;
}

class _ItemWeekdayStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ItemWeekdayStatsRef {
  _ItemWeekdayStatsProviderElement(super.provider);

  @override
  int get menuId => (origin as ItemWeekdayStatsProvider).menuId;
  @override
  int get weeksBack => (origin as ItemWeekdayStatsProvider).weeksBack;
  @override
  int get weekday => (origin as ItemWeekdayStatsProvider).weekday;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
