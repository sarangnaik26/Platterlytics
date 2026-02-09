import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import 'analytics_providers.dart';
import '../../settings/presentation/bill_settings_provider.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../settings/presentation/date_format_provider.dart';

enum AnalyticsMode { daily, range, weekday }

class SalesDetailsPage extends ConsumerStatefulWidget {
  const SalesDetailsPage({super.key});

  @override
  ConsumerState<SalesDetailsPage> createState() => _SalesDetailsPageState();
}

class _SalesDetailsPageState extends ConsumerState<SalesDetailsPage> {
  AnalyticsMode _selectedMode = AnalyticsMode.daily;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;
  int _selectedWeekday = DateTime.now().weekday; // 1=Mon, ..., 7=Sun

  @override
  void initState() {
    super.initState();
    // Default range: This week
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatDate = ref.watch(formatDateProvider);
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final formattedStart = DateFormat(
      'yyyy-MM-dd',
    ).format(selectedRange!.start);
    final formattedEnd = DateFormat('yyyy-MM-dd').format(selectedRange!.end);

    final settingsAsync = ref.watch(analyticsSettingsControllerProvider);
    final int weeksBack = settingsAsync.value ?? 4;

    AsyncValue<Map<String, dynamic>>? statsAsync;

    switch (_selectedMode) {
      case AnalyticsMode.daily:
        statsAsync = ref.watch(dailyStatsProvider(formattedDate));
        break;
      case AnalyticsMode.range:
        statsAsync = ref.watch(
          rangeStatsProvider(formattedStart, formattedEnd),
        );
        break;
      case AnalyticsMode.weekday:
        if (_selectedWeekday == 0) {
          // 0 represents "Week" (Consolidated)
          statsAsync = ref.watch(weeklyStatsProvider(weeksBack));
        } else {
          statsAsync = ref.watch(
            weekdayStatsProvider(weeksBack, _selectedWeekday),
          );
        }
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Details")),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SegmentedButton<AnalyticsMode>(
                  segments: const [
                    ButtonSegment(
                      value: AnalyticsMode.daily,
                      label: Text("Daily"),
                    ),
                    ButtonSegment(
                      value: AnalyticsMode.range,
                      label: Text("Range"),
                    ),
                    ButtonSegment(
                      value: AnalyticsMode.weekday,
                      label: Text("Weekday"),
                    ),
                  ],
                  selected: {_selectedMode},
                  onSelectionChanged: (Set<AnalyticsMode> newSelection) {
                    setState(() {
                      _selectedMode = newSelection.first;
                    });
                  },
                ),
                if (_selectedMode == AnalyticsMode.weekday) ...[
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(8, (index) {
                        // Increased to 8 to include "Week"
                        // 0 = Week, 1=Mon, ..., 7=Sun
                        final dayIndex = index;
                        final isSelected = _selectedWeekday == dayIndex;
                        const labels = [
                          "Week", // Index 0
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(labels[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedWeekday = dayIndex;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (_selectedMode == AnalyticsMode.daily)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDate: selectedDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          if (_selectedMode == AnalyticsMode.range) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          label: const Text("This Week"),
                          onPressed: () {
                            final now = DateTime.now();
                            setState(() {
                              selectedRange = DateTimeRange(
                                start: now.subtract(
                                  Duration(days: now.weekday - 1),
                                ),
                                end: now,
                              );
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text("This Month"),
                          onPressed: () {
                            final now = DateTime.now();
                            setState(() {
                              selectedRange = DateTimeRange(
                                start: DateTime(now.year, now.month, 1),
                                end: now,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: selectedRange,
                      );
                      if (picked != null) {
                        setState(() => selectedRange = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "${formatDate(selectedRange!.start)} - ${formatDate(selectedRange!.end)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],

          // Content
          Expanded(
            child: statsAsync!.when(
              data: (data) {
                if (_selectedMode == AnalyticsMode.weekday) {
                  return _buildWeekdayContent(data, weeksBack);
                } else {
                  return _buildStandardContent(data);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardContent(Map<String, dynamic> data) {
    final totalSales = (data['totalSales'] as num).toDouble();
    final billCount = data['billCount'] as int;
    final avgBill = (data['avgBillValue'] as num).toDouble();
    final chartData = _selectedMode == AnalyticsMode.range
        ? data['dailySales'] as List<Map<String, dynamic>>
        : data['hourlySales'] as List<Map<String, dynamic>>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Metrics
        Row(
          children: [
            Consumer(
              builder: (context, ref, child) {
                return _MetricCard(
                  "Total Sales",
                  ref.watch(formatCurrencyProvider(totalSales)),
                  Colors.green,
                );
              },
            ),
            const SizedBox(width: 8),
            _MetricCard("Bills", billCount.toString(), Colors.blue),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                return _MetricCard(
                  "Avg Bill",
                  ref.watch(formatCurrencyProvider(avgBill)),
                  Colors.orange,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chart
        SizedBox(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: _selectedMode == AnalyticsMode.range
                  ? (chartData.length * 60.0).clamp(
                      MediaQuery.of(context).size.width - 32,
                      double.infinity,
                    )
                  : (chartData.length * 50.0).clamp(
                      MediaQuery.of(context).size.width - 32,
                      double.infinity,
                    ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < chartData.length) {
                                final item = chartData[value.toInt()];
                                if (_selectedMode == AnalyticsMode.range) {
                                  final d = DateTime.tryParse(item['date']);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final formatDate = ref.watch(
                                          formatDateProvider,
                                        );
                                        if (d == null) return const Text('');
                                        final formatted = formatDate(d);
                                        // Show only Day/Month for bottom titles to keep it clean
                                        final parts = formatted.split('/');
                                        String displayLabels;
                                        if (parts.length >= 2) {
                                          if (formatted.startsWith(
                                            RegExp(r'\d{4}'),
                                          )) {
                                            // yyyy/MM/dd -> MM/dd
                                            displayLabels =
                                                '${parts[1]}/${parts[2]}';
                                          } else {
                                            // dd/MM/yyyy -> dd/MM
                                            displayLabels =
                                                '${parts[0]}/${parts[1]}';
                                          }
                                        } else {
                                          displayLabels = formatted;
                                        }
                                        return Text(
                                          displayLabels,
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "${item['hour']}:00",
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 2,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toStringAsFixed(0),
                              const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(chartData.length, (index) {
                        final item = chartData[index];
                        final val = (item['sales'] as num?)?.toDouble() ?? 0.0;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: val,
                              color: AppColors.primary,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        // High/Low Analysis
        if (chartData.isNotEmpty) ...[
          _buildAnalysisSection(
            chartData,
            _selectedMode == AnalyticsMode.range,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildWeekdayContent(Map<String, dynamic> data, int weeksBack) {
    String getDayName(int w) {
      if (w == 0) return "Week";
      switch (w) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
        default:
          return "";
      }
    }

    final label = "${getDayName(_selectedWeekday)} Overview";

    final avgSales = (data['avgSales'] as num).toDouble();
    final avgBills = (data['avgBills'] as num).toDouble(); // double in repo
    final latestSnapshot = data['latest'] as Map<String, dynamic>?;
    final trend = data['trend'] as Map<String, dynamic>;
    final contribution = (data['contribution'] as num).toDouble();
    final topItems = data['topItems'] as List<dynamic>; // of Map
    final history = data['history'] as List<dynamic>; // of Map

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No data available for this weekday.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          "Based on last ${data['totalWeeks'] ?? weeksBack} ${_selectedWeekday == 0 ? 'Weeks' : '${getDayName(_selectedWeekday)}s'}",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Key Metrics
        Row(
          children: [
            Consumer(
              builder: (context, ref, _) => _MetricCard(
                "Avg Sales",
                ref.watch(formatCurrencyProvider(avgSales)),
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            _MetricCard("Avg Bills", avgBills.toStringAsFixed(1), Colors.teal),
          ],
        ),
        const SizedBox(height: 16),
        // Latest Week Snapshot
        if (latestSnapshot != null) ...[
          Card(
            child: ListTile(
              title: Text(
                _selectedWeekday == 0 && latestSnapshot.containsKey('weekRange')
                    ? "Latest Week (${latestSnapshot['weekRange']})"
                    : "Latest Week Snapshot",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Consumer(
                builder: (context, ref, _) {
                  final s = (latestSnapshot['sales'] as num).toDouble();
                  final b = (latestSnapshot['bills'] as int);
                  return Text(
                    "Sales: ${ref.watch(formatCurrencyProvider(s))} • Bills: $b",
                  );
                },
              ),
              trailing: const Icon(Icons.history),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Trend & Stability
        Row(
          children: [
            Expanded(
              child: _TrendCard(
                label: "Growth",
                value:
                    "${((trend['growth'] as double) * 100).toStringAsFixed(1)}%",
                subLabel: "week-over-week",
                color: (trend['growth'] as double) >= 0
                    ? Colors.green
                    : Colors.red,
                icon: (trend['growth'] as double) >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TrendCard(
                label: "Consistency",
                value: trend['consistency'] as String,
                subLabel: "sales stability",
                color: Colors.blueGrey,
                icon: Icons.show_chart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedWeekday !=
            0) // Hide contribution for "Week" view if not relevant, or show as 100%
          Card(
            color: const Color(0xFFFFF8E1),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${getDayName(_selectedWeekday)} contributes ${(contribution * 100).toStringAsFixed(1)}% of weekly sales",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedWeekday != 0) const SizedBox(height: 24),

        // Best Selling Items
        const Text(
          "Best Selling Items",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...topItems.map((item) {
          final name = item['item_name'];
          // Calculate percentage contribution
          // totalSales for the period = avgSales * totalWeeks
          final totalWeeks = data['totalWeeks'] as int? ?? weeksBack;
          final totalPeriodSales = avgSales * totalWeeks;
          final itemTotal = (item['total'] as num?)?.toDouble() ?? 0.0;

          double percentage = 0;
          if (totalPeriodSales > 0) {
            percentage = (itemTotal / totalPeriodSales) * 100;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(name[0].toUpperCase())),
              title: Text(name),
              trailing: Text("${percentage.toStringAsFixed(1)}%"),
            ),
          );
        }),
        if (topItems.isEmpty) const Text("No item data available."),

        const SizedBox(height: 24),
        // History Chart
        const Text(
          "Sales History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < history.length) {
                        // History is expected to be chronological now?
                        // Repo: ORDER BY date DESC (reversed) -> So history[0] is oldest, history[last] is newest.
                        // But we want to show Last 5 Mondays.
                        // Let's check repository logic.
                        // "List<Map<String, dynamic>> history = List.from(result.reversed);"
                        // Result was DESC (latest first). Reversed -> oldest first. Correct.
                        final item = history[value.toInt()];
                        // Check if it's a weekday date or week range/id
                        // Week ID from getWeeklySalesStats is YYYY-WW (e.g. 2024-05)
                        // Weekday dates are YYYY-MM-DD

                        // For Weekly View: Display Week Number or Start Date
                        if (_selectedWeekday == 0) {
                          final range = item['weekRange'] as String? ?? "";
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              range,
                              style: const TextStyle(fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        // For Weekday View:
                        final d = DateTime.tryParse(item['date']);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Consumer(
                            builder: (context, ref, _) {
                              if (d == null) return const Text('?');
                              final formatDate = ref.watch(formatDateProvider);
                              return Text(
                                '${formatDate(d).split('/')[0]}/${formatDate(d).split('/')[1]}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 2,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(0),
                      const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(history.length, (index) {
                final item = history[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (item['sales'] as num).toDouble(),
                      color: AppColors.primary,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(List<Map<String, dynamic>> data, bool isRange) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Find High and Low
    Map<String, dynamic> highest = data.first;
    Map<String, dynamic> lowest = data.first;

    for (var item in data) {
      final sales = (item['sales'] as num).toDouble();
      final highSales = (highest['sales'] as num).toDouble();
      final lowSales = (lowest['sales'] as num).toDouble();

      if (sales > highSales) highest = item;
      if (sales < lowSales) lowest = item;
    }

    String getLabel(Map<String, dynamic> item) {
      if (isRange) {
        return ref.read(formatDateProvider)(DateTime.parse(item['date']));
      } else {
        return "${item['hour']}:00 - ${item['hour']}:59";
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Sales Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Highest Sales",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          return Text(
                            ref.watch(
                              formatCurrencyProvider(
                                (highest['sales'] as num).toDouble(),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        getLabel(highest),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey.shade300),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Lowest Sales",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          return Text(
                            ref.watch(
                              formatCurrencyProvider(
                                (lowest['sales'] as num).toDouble(),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        getLabel(lowest),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MetricCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final Color color;
  final IconData icon;

  const _TrendCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subLabel,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
