import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';
import '../domain/bill_model.dart';

class BillRepository {
  final DatabaseHelper _dbHelper;

  BillRepository(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  Future<int> createBill(Bill bill) async {
    final db = await _db;
    return await db.transaction((txn) async {
      // Insert Bill
      final billId = await txn.insert('bill', bill.toMap());

      // Insert Bill Items
      for (var item in bill.items) {
        final itemMap = item.toMap();
        itemMap['bill_id'] = billId;
        itemMap.remove('id'); // Ensure new ID
        await txn.insert('bill_items', itemMap);
      }
      return billId;
    });
  }

  Future<List<Bill>> getBills({String? date}) async {
    final db = await _db;
    String? where;
    List<Object?>? whereArgs;

    if (date != null) {
      where = 'date = ?';
      whereArgs = [date];
    }

    final maps = await db.query(
      'bill',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'bill_id DESC',
    );
    List<Bill> bills = [];

    for (var map in maps) {
      final billId = map['bill_id'] as int;
      final itemMaps = await db.query(
        'bill_items',
        where: 'bill_id = ?',
        whereArgs: [billId],
      );

      final items = itemMaps
          .map(
            (e) => BillItem(
              id: e['id'] as int?,
              billId: e['bill_id'] as int?,
              menuId: e['menu_id'] as int,
              itemName: e['item_name'] as String,
              unit: e['unit'] as String,
              quantity: (e['quantity'] as num).toDouble(),
              price: e['price'] as double,
              totalItemPrice: e['total_item_price'] as double,
            ),
          )
          .toList();

      bills.add(
        Bill(
          billId: billId,
          totalPrice: map['total_price'] as double,
          date: map['date'] as String,
          time: map['time'] as String,
          items: items,
        ),
      );
    }
    return bills;
  }

  Future<void> deleteBill(int billId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('bill_items', where: 'bill_id = ?', whereArgs: [billId]);
      await txn.delete('bill', where: 'bill_id = ?', whereArgs: [billId]);
    });
  }

  Future<int> deleteBillsOlderThan(DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().substring(
      0,
      10,
    ); // Format YYYY-MM-DD

    // Get IDs of bills to delete
    final result = await db.query(
      'bill',
      columns: ['bill_id'],
      where: 'date < ?',
      whereArgs: [dateStr],
    );

    final ids = result.map((r) => r['bill_id'] as int).toList();
    if (ids.isEmpty) return 0;

    final count = await db.transaction((txn) async {
      // Delete items first
      await txn.delete(
        'bill_items',
        where: 'bill_id IN (${ids.join(',')})', // Safe since IDs are ints
      );
      // Delete bills
      return await txn.delete('bill', where: 'bill_id IN (${ids.join(',')})');
    });

    return count;
  }
}

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(DatabaseHelper.instance);
});
