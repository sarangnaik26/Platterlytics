import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';
import '../domain/bill_model.dart';
import 'package:intl/intl.dart';

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
              quantity: e['quantity'] as int,
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
}

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(DatabaseHelper.instance);
});
