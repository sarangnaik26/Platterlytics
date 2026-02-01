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

    final totalSales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final billCount = (result.first['count'] as num?)?.toInt() ?? 0;
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

    final totalSales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final billCount = (result.first['count'] as num?)?.toInt() ?? 0;
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

  // Sales Details: Weekday
  Future<Map<String, dynamic>> getWeekdaySalesStats(
    int weeksBack,
    int weekday, // 1=Mon, ..., 7=Sun
  ) async {
    final db = await _db;
    final now = DateTime.now();
    // SQLite %w: 0=Sun, 1=Mon, ..., 6=Sat
    final sqliteWeekday = weekday == 7 ? 0 : weekday;

    // Calculate dates for the last N weekdays
    // We look back enough days to cover N occurrences. 1 week = 7 days.
    // Safety buffer: (weeksBack + 2) * 7 days
    final startDate = now
        .subtract(Duration(days: (weeksBack + 2) * 7))
        .toIso8601String()
        .split('T')[0];
    final todayStr = now.toIso8601String().split('T')[0];

    // Query for specific weekdays in range
    final result = await db.rawQuery(
      '''
      SELECT date, SUM(total_price) as sales, COUNT(*) as bill_count
      FROM bill
      WHERE date >= ? AND date <= ? AND strftime('%w', date) = ?
      GROUP BY date
      ORDER BY date DESC
      LIMIT ?
      ''',
      [startDate, todayStr, '$sqliteWeekday', weeksBack],
    );

    // Filter to ensure we only have the requested number of weeks
    List<Map<String, dynamic>> history = List.from(result.reversed);

    // If no data
    if (history.isEmpty) {
      return {
        'avgSales': 0.0,
        'avgBills': 0.0,
        'latest': null,
        'trend': {'growth': 0.0, 'consistency': 'N/A'},
        'contribution': 0.0,
        'topItems': [],
        'history': [],
        'totalWeeks': 0,
      };
    }

    // Key Metrics
    double totalSales = 0;
    int totalBills = 0;
    for (var day in history) {
      totalSales += (day['sales'] as num).toDouble();
      totalBills += (day['bill_count'] as int);
    }
    double avgSales = totalSales / history.length;
    double avgBills = totalBills / history.length;

    // Latest Snapshot
    final latestDay = history.last;
    final latestDate = latestDay['date'] as String;

    // Top Items for Weekday (Aggregate across all occurrences)
    final dateList = history.map((e) => "'${e['date']}'").join(',');
    final topItemsData = await db.rawQuery('''
      SELECT bi.item_name, SUM(bi.quantity) as qty, SUM(bi.total_item_price) as total
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE b.date IN ($dateList)
      GROUP BY bi.item_name
      ORDER BY total DESC
      LIMIT 5
      ''');

    // Latest Snapshot Top Items
    final latestTopItemsData = await db.rawQuery(
      '''
      SELECT bi.item_name, SUM(bi.quantity) as qty
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE b.date = ?
      GROUP BY bi.item_name
      ORDER BY qty DESC
      LIMIT 3
      ''',
      [latestDate],
    );

    // Trend (Growth vs previous available weekday)
    double growth = 0.0;
    if (history.length >= 2) {
      final current = (history.last['sales'] as num).toDouble();
      final prev = (history[history.length - 2]['sales'] as num).toDouble();
      if (prev > 0) {
        growth = (current - prev) / prev;
      }
    }

    // Consistency (Variance relative to mean)
    double consistencyMetric = 0.0;
    String consistencyLabel = "Stable";
    if (history.length > 1) {
      double min = double.infinity;
      double max = double.negativeInfinity;
      for (var day in history) {
        final s = (day['sales'] as num).toDouble();
        if (s < min) min = s;
        if (s > max) max = s;
      }
      if (avgSales > 0) {
        consistencyMetric = (max - min) / avgSales;
        if (consistencyMetric > 0.3) consistencyLabel = "Variable";
      }
    }

    // Contribution (Weekday sales vs Total Sales in the same period)
    final totalPeriodSalesResult = await db.rawQuery(
      '''
      SELECT SUM(total_price) as total
      FROM bill
      WHERE date >= ? AND date <= ?
      ''',
      [history.first['date'], latestDate],
    );
    double totalPeriodSales =
        (totalPeriodSalesResult.first['total'] as num?)?.toDouble() ?? 1.0;
    if (totalPeriodSales == 0) totalPeriodSales = 1.0;

    double contribution = totalSales / totalPeriodSales;

    return {
      'avgSales': avgSales,
      'avgBills': avgBills,
      'latest': {
        'date': latestDate,
        'sales': (latestDay['sales'] as num).toDouble(),
        'bills': (latestDay['bill_count'] as int),
        'topItems': latestTopItemsData,
      },
      'trend': {'growth': growth, 'consistency': consistencyLabel},
      'contribution': contribution,
      'topItems': topItemsData,
      'history': history,
      'totalWeeks': history.length,
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

    final totalSales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final billCount = (result.first['count'] as num?)?.toInt() ?? 0;
    final totalQty = (result.first['qty'] as num?)?.toInt() ?? 0;

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

    final totalSales = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final billCount = (result.first['count'] as num?)?.toInt() ?? 0;
    final totalQty = (result.first['qty'] as num?)?.toInt() ?? 0;

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

  // Item Analytics: Weekday
  Future<Map<String, dynamic>> getItemWeekdayStats(
    int menuId,
    int weeksBack,
    int weekday, // 1=Mon, ..., 7=Sun
  ) async {
    final db = await _db;
    final now = DateTime.now();
    final sqliteWeekday = weekday == 7 ? 0 : weekday;

    final startDate = now
        .subtract(Duration(days: (weeksBack + 2) * 7))
        .toIso8601String()
        .split('T')[0];
    final todayStr = now.toIso8601String().split('T')[0];

    // History for selected weekday
    final result = await db.rawQuery(
      '''
      SELECT b.date, SUM(bi.quantity) as qty, SUM(bi.total_item_price) as total
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ? AND strftime('%w', b.date) = ?
      GROUP BY b.date
      ORDER BY b.date DESC
      LIMIT ?
      ''',
      [menuId, startDate, todayStr, '$sqliteWeekday', weeksBack],
    );

    List<Map<String, dynamic>> history = List.from(result.reversed);

    if (history.isEmpty) {
      return {
        'avgQty': 0.0,
        'latest': null,
        'trend': {'growth': 0.0, 'consistency': 'N/A'},
        'contribution': 0.0,
        'history': [],
        'peakDay': 'N/A',
      };
    }

    double totalItemSales = 0;
    int totalItemQty = 0;
    for (var day in history) {
      totalItemSales += (day['total'] as num).toDouble();
      totalItemQty += (day['qty'] as int);
    }
    double avgQty = totalItemQty / history.length;

    // Latest Snapshot
    final latestDay = history.last;
    final latestDate = latestDay['date'] as String;

    // Co-selling items for latest date
    final coSellingData = await db.rawQuery(
      '''
      SELECT bi2.item_name, COUNT(*) as frequency
      FROM bill_items bi1
      JOIN bill_items bi2 ON bi1.bill_id = bi2.bill_id
      JOIN bill b ON bi1.bill_id = b.bill_id
      WHERE bi1.menu_id = ? AND bi2.menu_id != ? AND b.date = ?
      GROUP BY bi2.item_name
      ORDER BY frequency DESC
      LIMIT 3
      ''',
      [menuId, menuId, latestDate],
    );

    // Trend
    double growth = 0.0;
    if (history.length >= 2) {
      final current = (history.last['qty'] as num).toDouble();
      final prev = (history[history.length - 2]['qty'] as num).toDouble();
      if (prev > 0) {
        growth = (current - prev) / prev;
      }
    }

    // Consistency
    double consistencyMetric = 0.0;
    String consistencyLabel = "Stable";
    if (history.length > 1) {
      double min = double.infinity;
      double max = double.negativeInfinity;
      for (var day in history) {
        final q = (day['qty'] as num).toDouble();
        if (q < min) min = q;
        if (q > max) max = q;
      }
      if (avgQty > 0) {
        consistencyMetric = (max - min) / avgQty;
        if (consistencyMetric > 0.3) consistencyLabel = "Variable";
      }
    }

    // Contribution (Item Sales vs Total Sales on that weekday)
    // We already have Total Sales for that weekday in getWeekdaySalesStats, but here we calculate specifically.
    // We can just get total sales for these specific dates.
    final dateList = history.map((e) => "'${e['date']}'").join(',');
    final totalSalesOnDaysResult = await db.rawQuery('''
      SELECT SUM(total_price) as total
      FROM bill
      WHERE date IN ($dateList)
      ''');
    double totalSalesOnDays =
        (totalSalesOnDaysResult.first['total'] as num?)?.toDouble() ?? 1.0;
    if (totalSalesOnDays == 0) totalSalesOnDays = 1.0;

    double contribution = totalItemSales / totalSalesOnDays;

    // Best Selling Weekday (Peak Day)
    // Check all weekdays in the period
    final peakDayResult = await db.rawQuery(
      '''
      SELECT strftime('%w', b.date) as wday, AVG(bi.quantity) as avg_qty
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
      GROUP BY wday
      ORDER BY avg_qty DESC
      LIMIT 1
      ''',
      [menuId, startDate, todayStr],
    );

    String peakDayStr = "N/A";
    if (peakDayResult.isNotEmpty) {
      final w = int.parse(peakDayResult.first['wday'] as String);
      const days = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
      peakDayStr = days[w];
    }

    return {
      'avgQty': avgQty,
      'latest': {
        'date': latestDate,
        'qty': (latestDay['qty'] as int),
        'coSelling': coSellingData,
      },
      'trend': {'growth': growth, 'consistency': consistencyLabel},
      'contribution': contribution,
      'history': history,
      'peakDay': peakDayStr,
    };
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(DatabaseHelper.instance);
});
