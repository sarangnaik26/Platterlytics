// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'3742c317301b4fd26c4753593a838a2f558e7b35';

/// See also [Categories].
@ProviderFor(Categories)
final categoriesProvider =
    AutoDisposeAsyncNotifierProvider<Categories, List<Category>>.internal(
      Categories.new,
      name: r'categoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Categories = AutoDisposeAsyncNotifier<List<Category>>;
String _$menuItemsHash() => r'408013617dad8ae2f4f72ee31a0f7f3ffef5f0fc';

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

abstract class _$MenuItems
    extends BuildlessAutoDisposeAsyncNotifier<List<MenuItem>> {
  late final int? categoryId;

  FutureOr<List<MenuItem>> build({int? categoryId});
}

/// See also [MenuItems].
@ProviderFor(MenuItems)
const menuItemsProvider = MenuItemsFamily();

/// See also [MenuItems].
class MenuItemsFamily extends Family<AsyncValue<List<MenuItem>>> {
  /// See also [MenuItems].
  const MenuItemsFamily();

  /// See also [MenuItems].
  MenuItemsProvider call({int? categoryId}) {
    return MenuItemsProvider(categoryId: categoryId);
  }

  @override
  MenuItemsProvider getProviderOverride(covariant MenuItemsProvider provider) {
    return call(categoryId: provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'menuItemsProvider';
}

/// See also [MenuItems].
class MenuItemsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MenuItems, List<MenuItem>> {
  /// See also [MenuItems].
  MenuItemsProvider({int? categoryId})
    : this._internal(
        () => MenuItems()..categoryId = categoryId,
        from: menuItemsProvider,
        name: r'menuItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$menuItemsHash,
        dependencies: MenuItemsFamily._dependencies,
        allTransitiveDependencies: MenuItemsFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  MenuItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int? categoryId;

  @override
  FutureOr<List<MenuItem>> runNotifierBuild(covariant MenuItems notifier) {
    return notifier.build(categoryId: categoryId);
  }

  @override
  Override overrideWith(MenuItems Function() create) {
    return ProviderOverride(
      origin: this,
      override: MenuItemsProvider._internal(
        () => create()..categoryId = categoryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MenuItems, List<MenuItem>>
  createElement() {
    return _MenuItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MenuItemsProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MenuItemsRef on AutoDisposeAsyncNotifierProviderRef<List<MenuItem>> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _MenuItemsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MenuItems, List<MenuItem>>
    with MenuItemsRef {
  _MenuItemsProviderElement(super.provider);

  @override
  int? get categoryId => (origin as MenuItemsProvider).categoryId;
}

String _$menuControllerHash() => r'3c383d4b37b75fe0a7495e1fe11b6b394fe06307';

/// See also [MenuController].
@ProviderFor(MenuController)
final menuControllerProvider =
    AutoDisposeAsyncNotifierProvider<MenuController, void>.internal(
      MenuController.new,
      name: r'menuControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MenuController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
