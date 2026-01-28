import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';

class AnalyticsRepository {
  final DatabaseHelper _dbHelper;

  AnalyticsRepository(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  // Sales Details: Daily
  Future<Map<String, dynamic>> getDailySalesStats(String date) async {
    final db = await _db;

    // Total Sales
    final result = await db.rawQuery(
      'SELECT SUM(total_price) as total, COUNT(*) as count FROM bill WHERE date = ?',
      [date],
    );

    final totalSales = (result.first['total'] as double?) ?? 0.0;
    final billCount = (result.first['count'] as int?) ?? 0;
    final avgBillValue = billCount == 0 ? 0.0 : totalSales / billCount;

    // Hourly Sales for Chart
    final hourlyData = await db.rawQuery(
      '''
      SELECT SUBSTR(time, 1, 2) as hour, SUM(total_price) as sales
      FROM bill
      WHERE date = ?
      GROUP BY hour
      ORDER BY hour
      ''',
      [date],
    );

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'avgBillValue': avgBillValue,
      'hourlySales': hourlyData, // List<Map<String, dynamic>>
    };
  }

  // Sales Details: Range
  Future<Map<String, dynamic>> getRangeSalesStats(
    String startDate,
    String endDate,
  ) async {
    final db = await _db;

    // Total Sales
    final result = await db.rawQuery(
      'SELECT SUM(total_price) as total, COUNT(*) as count FROM bill WHERE date >= ? AND date <= ?',
      [startDate, endDate],
    );

    final totalSales = (result.first['total'] as double?) ?? 0.0;
    final billCount = (result.first['count'] as int?) ?? 0;
    final avgBillValue = billCount == 0 ? 0.0 : totalSales / billCount;

    // Daily Sales for Chart
    final dailyData = await db.rawQuery(
      '''
      SELECT date, SUM(total_price) as sales
      FROM bill
      WHERE date >= ? AND date <= ?
      GROUP BY date
      ORDER BY date
      ''',
      [startDate, endDate],
    );

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'avgBillValue': avgBillValue,
      'dailySales': dailyData,
    };
  }

  // Item Analytics: Daily
  Future<Map<String, dynamic>> getItemDailyStats(
    int menuId,
    String date,
  ) async {
    final db = await _db;

    // Total Amount and Count
    final result = await db.rawQuery(
      '''
        SELECT SUM(bi.total_item_price) as total, COUNT(DISTINCT b.bill_id) as count, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date = ?
        ''',
      [menuId, date],
    );

    final totalSales = (result.first['total'] as double?) ?? 0.0;
    final billCount = (result.first['count'] as int?) ?? 0;
    final totalQty = (result.first['qty'] as int?) ?? 0;

    // Hourly Item Sales
    final hourlyData = await db.rawQuery(
      '''
        SELECT SUBSTR(b.time, 1, 2) as hour, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date = ?
        GROUP BY hour
        ORDER BY hour
        ''',
      [menuId, date],
    );

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'hourlyData': hourlyData,
    };
  }

  // Item Analytics: Range
  Future<Map<String, dynamic>> getItemRangeStats(
    int menuId,
    String startDate,
    String endDate,
  ) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
        SELECT SUM(bi.total_item_price) as total, COUNT(DISTINCT b.bill_id) as count, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
        ''',
      [menuId, startDate, endDate],
    );

    final totalSales = (result.first['total'] as double?) ?? 0.0;
    final billCount = (result.first['count'] as int?) ?? 0;
    final totalQty = (result.first['qty'] as int?) ?? 0;

    final dailyData = await db.rawQuery(
      '''
        SELECT b.date, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
        GROUP BY b.date
        ORDER BY b.date
        ''',
      [menuId, startDate, endDate],
    );

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'dailyData': dailyData,
    };
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(DatabaseHelper.instance);
});
