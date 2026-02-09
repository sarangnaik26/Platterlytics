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
    final totalQty = (result.first['qty'] as num?)?.toDouble() ?? 0.0;

    // Quantity Breakdown by Unit
    final qtyByUnitResult = await db.rawQuery(
      '''
        SELECT bi.unit, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date = ?
        GROUP BY bi.unit
        ORDER BY qty DESC
        ''',
      [menuId, date],
    );

    final Map<String, double> totalQtyByUnit = {
      for (var row in qtyByUnitResult)
        row['unit'] as String: (row['qty'] as num).toDouble(),
    };

    // Hourly Item Sales with Unit Breakdown
    final hourlyData = await db.rawQuery(
      '''
        SELECT SUBSTR(b.time, 1, 2) as hour, bi.unit, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date = ?
        GROUP BY hour, bi.unit
        ORDER BY hour
        ''',
      [menuId, date],
    );

    // Hourly Item Sales - Fill gaps
    // Structure: List of maps where each map represents an hour and contains quantities for each unit
    // e.g., [{'hour': '09', 'Full': 2.0, 'Half': 1.0}, ...]
    final List<Map<String, dynamic>> hourlyDataComplete = [];

    // Group raw data by hour
    final Map<String, Map<String, double>> groupedByHour = {};
    for (var row in hourlyData) {
      final h = row['hour'] as String;
      final u = row['unit'] as String;
      final q = (row['qty'] as num).toDouble();

      groupedByHour.putIfAbsent(h, () => {});
      groupedByHour[h]![u] = q;
    }

    for (int i = 0; i < 24; i++) {
      final h = i.toString().padLeft(2, '0');
      final hourData = groupedByHour[h] ?? {};
      hourlyDataComplete.add({
        'hour': h,
        ...hourData, // Spreads 'Full': 2.0, 'Half': 1.0 etc.
      });
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'totalQtyByUnit': totalQtyByUnit,
      'hourlyData': hourlyDataComplete,
      'units': totalQtyByUnit.keys.toList(), // Helpers list of unit names
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
    final totalQty = (result.first['qty'] as num?)?.toDouble() ?? 0.0;

    // Quantity Breakdown by Unit
    final qtyByUnitResult = await db.rawQuery(
      '''
        SELECT bi.unit, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
        GROUP BY bi.unit
        ORDER BY qty DESC
        ''',
      [menuId, startDate, endDate],
    );

    final Map<String, double> totalQtyByUnit = {
      for (var row in qtyByUnitResult)
        row['unit'] as String: (row['qty'] as num).toDouble(),
    };

    // Daily Data with Unit Breakdown
    final dailyData = await db.rawQuery(
      '''
        SELECT b.date, bi.unit, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
        GROUP BY b.date, bi.unit
        ORDER BY b.date
        ''',
      [menuId, startDate, endDate],
    );

    // Daily Item Sales - Fill gaps
    final List<Map<String, dynamic>> dailyDataComplete = [];

    // Group raw data by date
    final Map<String, Map<String, double>> groupedByDate = {};
    for (var row in dailyData) {
      final d = row['date'] as String;
      final u = row['unit'] as String;
      final q = (row['qty'] as num).toDouble();

      groupedByDate.putIfAbsent(d, () => {});
      groupedByDate[d]![u] = q;
    }

    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      final dateStr = d.toIso8601String().split('T')[0];
      final dateData = groupedByDate[dateStr] ?? {};
      dailyDataComplete.add({'date': dateStr, ...dateData});
    }

    return {
      'totalSales': totalSales,
      'billCount': billCount,
      'totalQty': totalQty,
      'totalQtyByUnit': totalQtyByUnit,
      'dailyData': dailyDataComplete,
      'units': totalQtyByUnit.keys.toList(),
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

    // Quantity Breakdown by Unit for this weekday
    final qtyByUnitResult = await db.rawQuery(
      '''
        SELECT bi.unit, SUM(bi.quantity) as qty
        FROM bill_items bi
        JOIN bill b ON bi.bill_id = b.bill_id
        WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ? AND strftime('%w', b.date) = ?
        GROUP BY bi.unit
        ORDER BY qty DESC
        ''',
      [menuId, startDate, todayStr, '$sqliteWeekday'],
    );
    final Map<String, double> totalQtyByUnit = {
      for (var row in qtyByUnitResult)
        row['unit'] as String: (row['qty'] as num).toDouble(),
    };

    // History for selected weekday (Grouped by Date and Unit)
    final result = await db.rawQuery(
      '''
      SELECT b.date, bi.unit, SUM(bi.quantity) as qty, SUM(bi.total_item_price) as total
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ? AND strftime('%w', b.date) = ?
      GROUP BY b.date, bi.unit
      ORDER BY b.date DESC
      ''',
      [menuId, startDate, todayStr, '$sqliteWeekday'],
    );

    // Group by Date for the history list
    final Map<String, Map<String, dynamic>> historyMap = {};
    for (var row in result) {
      final d = row['date'] as String;
      final u = row['unit'] as String;
      final q = (row['qty'] as num).toDouble();
      final t = (row['total'] as num).toDouble();

      if (!historyMap.containsKey(d)) {
        historyMap[d] = {'date': d, 'qty': 0.0, 'total': 0.0};
      }
      historyMap[d]!['qty'] = (historyMap[d]!['qty'] as double) + q;
      historyMap[d]!['total'] = (historyMap[d]!['total'] as double) + t;
      historyMap[d]![u] = q; // Add unit breakdown
    }

    // Sort desc by date and limit check (though date range does most of it)
    List<Map<String, dynamic>> history = historyMap.values.toList();
    history.sort((a, b) => b['date'].compareTo(a['date']));
    if (history.length > weeksBack + 2) {
      history = history.sublist(0, weeksBack + 2);
    }

    // Reverse for graph (oldest to newest) - actually implementation expects Reversed?
    // The previous implementation did `List.from(result.reversed);` where result was ORDER BY date DESC.
    // So history was [Oldest, ..., Newest].
    history = history.reversed.toList();

    if (history.isEmpty) {
      return {
        'avgQty': 0.0,
        'latest': null,
        'trend': {'growth': 0.0, 'consistency': 'N/A'},
        'contribution': 0.0,
        'history': [],
        'peakDay': 'N/A',
        'units': <String>[],
        'totalQtyByUnit': {},
      };
    }

    double totalItemSales = 0;
    double totalItemQty = 0;
    for (var day in history) {
      totalItemSales += (day['total'] as num).toDouble();
      totalItemQty += (day['qty'] as num).toDouble();
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
        'Sunday', // For SQLite %w 0 is Sunday
      ];
      // SQLite %w: 0-6 with 0=Sunday
      peakDayStr = days[w];
    }

    return {
      'avgQty': avgQty,
      'latest': {
        'date': latestDate,
        'qty': (latestDay['qty'] as num).toDouble(),
        'coSelling': coSellingData,
      },
      'trend': {'growth': growth, 'consistency': consistencyLabel},
      'contribution': contribution,
      'history': history,
      'peakDay': peakDayStr,
      'units': totalQtyByUnit.keys.toList(),
      'totalQtyByUnit': totalQtyByUnit,
    };
  }

  // Sales Details: Weekly (Consolidated)
  Future<Map<String, dynamic>> getWeeklySalesStats(int weeksBack) async {
    final db = await _db;
    final now = DateTime.now();
    // Start date: (weeksBack + 1) weeks ago to ensure we have comparison for the earliest week?
    // Actually typically "Last N weeks".
    final startDate = now
        .subtract(Duration(days: (weeksBack + 1) * 7))
        .toIso8601String()
        .split('T')[0];
    final todayStr = now.toIso8601String().split('T')[0];

    // Query grouped by Year-Week
    // SQLite strftime('%W') is week of year 00-53
    final result = await db.rawQuery(
      '''
      SELECT strftime('%Y-%W', date) as week_id, MIN(date) as start_date, SUM(total_price) as sales, COUNT(*) as bill_count
      FROM bill
      WHERE date >= ? AND date <= ?
      GROUP BY week_id
      ORDER BY week_id DESC
      LIMIT ?
      ''',
      [startDate, todayStr, weeksBack + 1], // Fetch +1 for growth calculation
    );

    List<Map<String, dynamic>> history = [];
    for (var row in result) {
      final map = Map<String, dynamic>.from(row);
      map['weekRange'] = _formatWeekRange(row['start_date'] as String? ?? "");
      history.add(map);
    }

    if (history.isEmpty) {
      return {
        'avgSales': 0.0,
        'avgBills': 0.0,
        'latest': null,
        'trend': {'growth': 0.0, 'consistency': 'N/A'},
        'contribution': 0.0, // N/A for weekly view potentially
        'topItems': [],
        'history': [],
        'totalWeeks': 0,
      };
    }

    // Latest fully completed week or current week?
    // Usually "Weekly" analytics might imply full weeks.
    // usage: history[0] is current/latest week.
    final latestWeek = history.first;
    // Use start_date as the identifier for the week in UI

    // Key Metrics (Average over the fetched weeks)
    double totalSales = 0;
    int totalBills = 0;
    for (var week in history) {
      totalSales += (week['sales'] as num).toDouble();
      totalBills += (week['bill_count'] as int);
    }
    double avgSales = totalSales / history.length;
    double avgBills = totalBills / history.length;

    // Trend
    double growth = 0.0;
    if (history.length >= 2) {
      final current = (history.first['sales'] as num).toDouble();
      final prev = (history[1]['sales'] as num).toDouble();
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
      for (var week in history) {
        final s = (week['sales'] as num).toDouble();
        if (s < min) min = s;
        if (s > max) max = s;
      }
      if (avgSales > 0) {
        consistencyMetric = (max - min) / avgSales;
        if (consistencyMetric > 0.3) consistencyLabel = "Variable";
      }
    }

    // Top Items for latest week
    // We need the date range for the latest week.
    // We have start_date. End date is start_date + 6 days.
    final latestWeekStart = latestWeek['start_date'] as String;
    final latestWeekEnd = DateTime.parse(
      latestWeekStart,
    ).add(const Duration(days: 6)).toIso8601String().split('T')[0];

    final topItemsData = await db.rawQuery(
      '''
      SELECT bi.item_name, SUM(bi.quantity) as qty, SUM(bi.total_item_price) as total
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE b.date >= ? AND b.date <= ?
      GROUP BY bi.item_name
      ORDER BY total DESC
      LIMIT 5
      ''',
      [latestWeekStart, latestWeekEnd],
    );

    // Reformat history for UI (needs to be oldest to newest usually for chart)
    // currently history is DESC (newest first).
    final chartHistory = history.reversed.toList();

    return {
      'avgSales': avgSales,
      'avgBills': avgBills,
      'latest': {
        'date': latestWeekStart, // Representative date
        'sales': (latestWeek['sales'] as num).toDouble(),
        'bills': (latestWeek['bill_count'] as int),
        'topItems': [], // Not using latest snapshot top items in same way
        'weekRange': _formatWeekRange(latestWeekStart),
      },
      'trend': {'growth': growth, 'consistency': consistencyLabel},
      'contribution':
          1.0, // Weekly contributes to 100% of itself? Or maybe vs month? Leaving as 1.0 or N/A
      'topItems': topItemsData,
      'history': chartHistory, // List of {week_id, start_date, sales, ...}
      'totalWeeks': history.length,
    };
  }

  String _formatWeekRange(String dateStr) {
    if (dateStr.isEmpty) return "";
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    // Find Monday
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    String format(DateTime d) {
      return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
    }

    return "${format(monday)} - ${format(sunday)}";
  }

  // Item Analytics: Weekly (Consolidated)
  Future<Map<String, dynamic>> getItemWeeklyStats(
    int menuId,
    int weeksBack,
  ) async {
    final db = await _db;
    final now = DateTime.now();
    final startDate = now
        .subtract(Duration(days: (weeksBack + 1) * 7))
        .toIso8601String()
        .split('T')[0];
    final todayStr = now.toIso8601String().split('T')[0];

    // Weekly history with unit breakdown
    final result = await db.rawQuery(
      '''
      SELECT strftime('%Y-%W', b.date) as week_id, MIN(b.date) as start_date, bi.unit, SUM(bi.quantity) as qty, SUM(bi.total_item_price) as total
      FROM bill_items bi
      JOIN bill b ON bi.bill_id = b.bill_id
      WHERE bi.menu_id = ? AND b.date >= ? AND b.date <= ?
      GROUP BY week_id, bi.unit
      ORDER BY week_id DESC
      ''',
      [menuId, startDate, todayStr],
    );

    // Group by Week
    final Map<String, Map<String, dynamic>> historyMap = {};
    for (var row in result) {
      final w = row['week_id'] as String;
      final u = row['unit'] as String; // Unit
      final q = (row['qty'] as num).toDouble();
      final t = (row['total'] as num).toDouble();
      final sd = row['start_date'] as String;

      if (!historyMap.containsKey(w)) {
        historyMap[w] = {
          'week_id': w,
          'start_date': sd,
          'qty': 0.0,
          'total': 0.0,
        };
      }
      historyMap[w]!['qty'] = (historyMap[w]!['qty'] as double) + q;
      historyMap[w]!['total'] = (historyMap[w]!['total'] as double) + t;
      historyMap[w]![u] = q; // Unit breakdown
    }

    // Flatten values and sort
    List<Map<String, dynamic>> history = historyMap.values.toList();
    // Add date range
    for (var h in history) {
      h['weekRange'] = _formatWeekRange(h['start_date'] as String? ?? "");
    }
    history.sort((a, b) => b['week_id'].compareTo(a['week_id']));
    if (history.length > weeksBack + 1) {
      history = history.sublist(0, weeksBack + 1);
    }

    if (history.isEmpty) {
      return {
        'avgQty': 0.0,
        'latest': null,
        'trend': {'growth': 0.0, 'consistency': 'N/A'},
        'contribution': 0.0,
        'history': [],
        'peakDay': 'N/A',
        'units': <String>[],
        'totalQtyByUnit': {},
      };
    }

    // Units presence
    final Set<String> unitsSet = {};
    for (var h in history) {
      for (var k in h.keys) {
        if (k != 'week_id' &&
            k != 'start_date' &&
            k != 'qty' &&
            k != 'total' &&
            k != 'weekRange') {
          unitsSet.add(k);
        }
      }
    }

    // Metrics
    double totalQty = 0;
    for (var week in history) {
      totalQty += (week['qty'] as num).toDouble();
    }
    double avgQty = totalQty / history.length;

    // Trend
    double growth = 0.0;
    if (history.length >= 2) {
      final current = (history.first['qty'] as num).toDouble();
      final prev = (history[1]['qty'] as num).toDouble();
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
      for (var w in history) {
        final q = (w['qty'] as num).toDouble();
        if (q < min) min = q;
        if (q > max) max = q;
      }
      if (avgQty > 0) {
        consistencyMetric = (max - min) / avgQty;
        if (consistencyMetric > 0.3) consistencyLabel = "Variable";
      }
    }

    // Calculate contribution (Item Sales / Total Sales for the weeks)
    // We need total sales for these weeks
    // This could be expensive. Approximation: get sum of all bill totals in range.
    // Or just 1.0 if not critical. User asked for "percentage of contribution" in previous task for weekday.
    // Likely wants it here too.

    // Total Sales in period
    // final latestWeekStart = history.first['start_date'];
    final oldestWeekStart = history.last['start_date'];
    // Approximately range
    final totalSalesResult = await db.rawQuery(
      '''
      SELECT SUM(total_price) as total FROM bill WHERE date >= ? AND date <= ?
    ''',
      [oldestWeekStart, todayStr],
    ); // Broad range

    double totalPeriodSales =
        (totalSalesResult.first['total'] as num?)?.toDouble() ?? 1.0;
    if (totalPeriodSales == 0) totalPeriodSales = 1.0;

    // Sum item sales
    double totalItemSales = 0;
    for (var w in history) {
      totalItemSales += (w['total'] as num).toDouble();
    }

    double contribution = totalItemSales / totalPeriodSales;

    // Latest Week
    final latestWeek = history.first;

    // Co-Selling (for latest week)
    final latestStart = latestWeek['start_date'] as String;
    final latestEnd = DateTime.parse(
      latestStart,
    ).add(Duration(days: 6)).toIso8601String().split('T')[0];

    final coSellingData = await db.rawQuery(
      '''
      SELECT bi2.item_name, COUNT(*) as frequency
      FROM bill_items bi1
      JOIN bill_items bi2 ON bi1.bill_id = bi2.bill_id
      JOIN bill b ON bi1.bill_id = b.bill_id
      WHERE bi1.menu_id = ? AND bi2.menu_id != ? AND b.date >= ? AND b.date <= ?
      GROUP BY bi2.item_name
      ORDER BY frequency DESC
      LIMIT 3
      ''',
      [menuId, menuId, latestStart, latestEnd],
    );

    return {
      'avgQty': avgQty,
      'latest': {
        'date': latestStart,
        'qty': (latestWeek['qty'] as num).toDouble(),
        'coSelling': coSellingData,
        'weekRange': _formatWeekRange(latestStart),
      },
      'trend': {'growth': growth, 'consistency': consistencyLabel},
      'contribution': contribution, // Ratio
      'history': history.reversed.toList(),
      'peakDay': 'N/A', // Not applicable for weekly view
      'units': unitsSet.toList(),
      'totalQtyByUnit':
          {}, // Not strictly needed for the weekly summary chart unless we aggregate
    };
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(DatabaseHelper.instance);
});
