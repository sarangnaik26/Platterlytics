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

    // Hourly Sales for Chart - Ensure all 24 hours or at least a full range
    final List<Map<String, dynamic>> hourlySales = [];
    final Map<String, double> hourlyMap = {
      for (var row in hourlyData)
        row['hour'] as String: (row['sales'] as num).toDouble(),
    };

    for (int i = 0; i < 24; i++) {
      final h = i.toString().padLeft(2, '0');
      hourlySales.add({'hour': h, 'sales': hourlyMap[h] ?? 0.0});
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'avgBillValue': avgBillValue,
      'hourlySales': hourlySales,
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

    // Daily Sales for Chart - Fill missing dates
    final List<Map<String, dynamic>> dailySales = [];
    final Map<String, double> dailyMap = {
      for (var row in dailyData)
        row['date'] as String: (row['sales'] as num).toDouble(),
    };

    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];
      dailySales.add({'date': dateStr, 'sales': dailyMap[dateStr] ?? 0.0});
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'avgBillValue': avgBillValue,
      'dailySales': dailySales,
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

    // Hourly Item Sales - Fill gaps
    final List<Map<String, dynamic>> hourlyDataComplete = [];
    final Map<String, int> hourlyMap = {
      for (var row in hourlyData) row['hour'] as String: row['qty'] as int,
    };
    for (int i = 0; i < 24; i++) {
      final h = i.toString().padLeft(2, '0');
      hourlyDataComplete.add({'hour': h, 'qty': hourlyMap[h] ?? 0});
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'hourlyData': hourlyDataComplete,
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

    // Daily Item Sales - Fill gaps
    final List<Map<String, dynamic>> dailyDataComplete = [];
    final Map<String, int> dailyMap = {
      for (var row in dailyData) row['date'] as String: row['qty'] as int,
    };
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];
      dailyDataComplete.add({'date': dateStr, 'qty': dailyMap[dateStr] ?? 0});
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'dailyData': dailyDataComplete,
    };
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(DatabaseHelper.instance);
});
