import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import 'analytics_providers.dart';

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
                          totalSales.toStringAsFixed(2),
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _MetricCard("Bills", billCount.toString(), Colors.blue),
                        const SizedBox(width: 8),
                        _MetricCard(
                          "Avg Bill",
                          avgBill.toStringAsFixed(2),
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart
                    SizedBox(
                      height: 300,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // Basic logic: Index based
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < chartData.length) {
                                        final item = chartData[value.toInt()];
                                        if (isRangeMode) {
                                          // Show date MM-dd
                                          final d = DateTime.tryParse(
                                            item['date'],
                                          );
                                          return Text(
                                            DateFormat('MM-dd').format(d!),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          );
                                        } else {
                                          // Show hour
                                          return Text(
                                            item['hour'],
                                            style: const TextStyle(
                                              fontSize: 10,
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
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(chartData.length, (
                                    index,
                                  ) {
                                    final item = chartData[index];
                                    final val =
                                        (item['sales'] as num?)?.toDouble() ??
                                        0.0;
                                    return FlSpot(index.toDouble(), val);
                                  }),
                                  isCurved: true,
                                  color: AppColors.primary,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
