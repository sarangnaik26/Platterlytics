import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';
import '../domain/category.dart';
import '../domain/menu_item.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper;

  MenuRepository(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  // Categories
  Future<List<Category>> getCategories() async {
    final db = await _db;
    final maps = await db.query('categories', orderBy: 'priority ASC');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> addCategory(Category category) async {
    final db = await _db;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await _db;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _db;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCategoryOrder(List<Category> categories) async {
    final db = await _db;
    final batch = db.batch();
    for (var cat in categories) {
      batch.update(
        'categories',
        cat.toMap(),
        where: 'id = ?',
        whereArgs: [cat.id],
      );
    }
    await batch.commit(noResult: true);
  }

  // Menu Items
  Future<List<MenuItem>> getMenuItems({int? categoryId}) async {
    final db = await _db;
    String? where;
    List<Object?>? whereArgs;
    if (categoryId != null) {
      where = 'category_id = ?';
      whereArgs = [categoryId];
    }

    final maps = await db.query('menu', where: where, whereArgs: whereArgs);
    List<MenuItem> items = [];

    for (var map in maps) {
      final menuItem = MenuItem.fromMap(map);
      final prices = await getMenuPrices(menuItem.menuId!);
      items.add(menuItem.copyWith(prices: prices));
    }
    return items;
  }

  Future<List<MenuPrice>> getMenuPrices(int menuId) async {
    final db = await _db;
    final maps = await db.query(
      'menu_prices',
      where: 'menu_id = ?',
      whereArgs: [menuId],
    );
    return maps.map((e) => MenuPrice.fromMap(e)).toList();
  }

  Future<int> addMenuItem(MenuItem item) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final menuId = await txn.insert('menu', item.toMap());
      for (var price in item.prices) {
        final priceMap = price.toMap();
        priceMap['menu_id'] = menuId;
        priceMap.remove('id'); // Ensure new ID
        await txn.insert('menu_prices', priceMap);
      }
      return menuId;
    });
  }

  Future<void> updateMenuItem(MenuItem item) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'menu',
        item.toMap(),
        where: 'menu_id = ?',
        whereArgs: [item.menuId],
      );
      // Replace prices: Delete all and re-insert
      await txn.delete(
        'menu_prices',
        where: 'menu_id = ?',
        whereArgs: [item.menuId],
      );
      for (var price in item.prices) {
        final priceMap = price.toMap();
        priceMap['menu_id'] = item.menuId;
        priceMap.remove('id');
        await txn.insert('menu_prices', priceMap);
      }
    });
  }

  Future<void> deleteMenuItem(int id) async {
    final db = await _db;
    await db.delete('menu', where: 'menu_id = ?', whereArgs: [id]);
    // Prices deleted via CASCADE
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(DatabaseHelper.instance);
});
