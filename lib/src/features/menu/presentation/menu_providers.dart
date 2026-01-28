import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/menu_repository.dart';
import '../domain/category.dart';
import '../domain/menu_item.dart';

part 'menu_providers.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(menuRepositoryProvider);
    return repository.getCategories();
  }

  Future<void> add(Category category) async {
    final repository = ref.read(menuRepositoryProvider);
    await repository.addCategory(category);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repository = ref.read(menuRepositoryProvider);
    await repository.deleteCategory(id);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(Category category) async {
    final repository = ref.read(menuRepositoryProvider);
    await repository.updateCategory(category);
    ref.invalidateSelf();
  }
}

@riverpod
class MenuItems extends _$MenuItems {
  @override
  Future<List<MenuItem>> build({int? categoryId}) async {
    final repository = ref.watch(menuRepositoryProvider);
    return repository.getMenuItems(categoryId: categoryId);
  }
}

@riverpod
class MenuController extends _$MenuController {
  @override
  FutureOr<void> build() {}

  Future<void> addMenuItem(MenuItem item) async {
    final repository = ref.read(menuRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.addMenuItem(item);
      ref.invalidate(menuItemsProvider);
    });
  }

  Future<void> deleteMenuItem(int id) async {
    final repository = ref.read(menuRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteMenuItem(id);
      ref.invalidate(menuItemsProvider);
    });
  }

  Future<void> updateMenuItem(MenuItem item) async {
    final repository = ref.read(menuRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateMenuItem(item);
      ref.invalidate(menuItemsProvider);
    });
  }
}
