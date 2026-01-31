import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import 'analytics_providers.dart';
import '../../settings/presentation/bill_settings_provider.dart';

class SalesDetailsPage extends ConsumerStatefulWidget {
  const SalesDetailsPage({super.key});

  @override
  ConsumerState<SalesDetailsPage> createState() => _SalesDetailsPageState();
}

class _SalesDetailsPageState extends ConsumerState<SalesDetailsPage> {
  bool isRangeMode = false;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;

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
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(selectedDate);
    final formattedStart = dateFormat.format(selectedRange!.start);
    final formattedEnd = dateFormat.format(selectedRange!.end);
    final statsAsync = isRangeMode
        ? ref.watch(rangeStatsProvider(formattedStart, formattedEnd))
        : ref.watch(dailyStatsProvider(formattedDate));

    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Details")),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text("Daily")),
                      ButtonSegment(value: true, label: Text("Range")),
                    ],
                    selected: {isRangeMode},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        isRangeMode = newSelection.first;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    if (isRangeMode) {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: selectedRange,
                      );
                      if (picked != null) {
                        setState(() => selectedRange = picked);
                      }
                    } else {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDate: selectedDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          if (isRangeMode) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ActionChip(
                    label: const Text("This Week"),
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() {
                        selectedRange = DateTimeRange(
                          start: now.subtract(Duration(days: now.weekday - 1)),
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
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text("Last 7 Days"),
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() {
                        selectedRange = DateTimeRange(
                          start: now.subtract(const Duration(days: 6)),
                          end: now,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (isRangeMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "$formattedStart - $formattedEnd",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                formattedDate,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Content
          Expanded(
            child: statsAsync.when(
              data: (data) {
                final totalSales = data['totalSales'] as double;
                final billCount = data['billCount'] as int;
                final avgBill = data['avgBillValue'] as double;
                final chartData = isRangeMode
                    ? data['dailySales'] as List<Map<String, dynamic>>
                    : data['hourlySales'] as List<Map<String, dynamic>>;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Metrics
                    Row(
                      children: [
                        _MetricCard(
                          "Total Sales",
                          "$symbol${totalSales.toStringAsFixed(2)}",
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _MetricCard("Bills", billCount.toString(), Colors.blue),
                        const SizedBox(width: 8),
                        _MetricCard(
                          "Avg Bill",
                          "$symbol${avgBill.toStringAsFixed(2)}",
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    // Chart
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: isRangeMode
                            ? (chartData.length * 60.0).clamp(
                                MediaQuery.of(context).size.width - 32,
                                double.infinity,
                              )
                            : (chartData.length * 50.0).clamp(
                                MediaQuery.of(context).size.width - 32,
                                double.infinity,
                              ),
                        height: 300,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < chartData.length) {
                                          final item = chartData[value.toInt()];
                                          if (isRangeMode) {
                                            final d = DateTime.tryParse(
                                              item['date'],
                                            );
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                DateFormat('MM-dd').format(d!),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                "${item['hour']}:00",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(chartData.length, (
                                  index,
                                ) {
                                  final item = chartData[index];
                                  final val =
                                      (item['sales'] as num?)?.toDouble() ??
                                      0.0;
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
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // High/Low Analysis
                    if (chartData.isNotEmpty) ...[
                      _buildAnalysisSection(chartData, symbol, isRangeMode),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(
    List<Map<String, dynamic>> data,
    String symbol,
    bool isRange,
  ) {
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
        return DateFormat('MMM dd, yyyy').format(DateTime.parse(item['date']));
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
                      Text(
                        "$symbol${(highest['sales'] as num).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                      Text(
                        "$symbol${(lowest['sales'] as num).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
        color: color.withOpacity(0.1),
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
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
