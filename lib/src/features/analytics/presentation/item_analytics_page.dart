import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../menu/domain/category.dart';
import '../../menu/domain/menu_item.dart';
import '../../menu/presentation/menu_providers.dart';
import 'analytics_providers.dart';
import '../../settings/presentation/bill_settings_provider.dart';

class ItemAnalyticsPage extends ConsumerStatefulWidget {
  const ItemAnalyticsPage({super.key});

  @override
  ConsumerState<ItemAnalyticsPage> createState() => _ItemAnalyticsPageState();
}

class _ItemAnalyticsPageState extends ConsumerState<ItemAnalyticsPage> {
  int? _selectedCategoryId;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Item Analytics")),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Categories
          SizedBox(
            height: 60,
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: const Text("All"),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) =>
                            setState(() => _selectedCategoryId = null),
                      );
                    }
                    final category = categories[index - 1];
                    final isSelected = _selectedCategoryId == category.id;
                    return ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) => setState(
                        () =>
                            _selectedCategoryId = selected ? category.id : null,
                      ),
                      selectedColor: Color(category.color).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? Color(category.color) : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(),
            ),
          ),

          const Divider(),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) => _ItemAnalyticsList(
                categories: categories,
                selectedCategoryId: _selectedCategoryId,
                searchQuery: _searchQuery,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemAnalyticsList extends ConsumerWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final String searchQuery;

  const _ItemAnalyticsList({
    required this.categories,
    this.selectedCategoryId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCategories = List<Category>.from(categories);
    if (selectedCategoryId != null) {
      final selectedIndex = displayCategories.indexWhere(
        (c) => c.id == selectedCategoryId,
      );
      if (selectedIndex != -1) {
        final selected = displayCategories.removeAt(selectedIndex);
        displayCategories.insert(0, selected);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        return _CategoryAnalyticsCard(
          category: displayCategories[index],
          searchQuery: searchQuery,
        );
      },
    );
  }
}

class _CategoryAnalyticsCard extends ConsumerWidget {
  final Category category;
  final String searchQuery;

  const _CategoryAnalyticsCard({
    required this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(
      menuItemsProvider(categoryId: category.id),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(category.color), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(category.color).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              category.name,
              style: TextStyle(
                color: Color(category.color),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          menuItemsAsync.when(
            data: (items) {
              // Filter
              final filetered = items
                  .where(
                    (i) => i.itemName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();
              if (filetered.isEmpty) return const SizedBox.shrink();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filetered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filetered[index];
                  return ListTile(
                    title: Text(item.itemName),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _showItemAnalysis(context, item);
                      },
                      child: const Text("Analyze"),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (e, s) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showItemAnalysis(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ItemAnalysisModal(item: item),
    );
  }
}

class _ItemAnalysisModal extends ConsumerStatefulWidget {
  final MenuItem item;
  const _ItemAnalysisModal({required this.item});

  @override
  ConsumerState<_ItemAnalysisModal> createState() => _ItemAnalysisModalState();
}

class _ItemAnalysisModalState extends ConsumerState<_ItemAnalysisModal> {
  bool isRangeMode = true;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
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
        ? ref.watch(
            itemRangeStatsProvider(
              widget.item.menuId!,
              formattedStart,
              formattedEnd,
            ),
          )
        : ref.watch(itemDailyStatsProvider(widget.item.menuId!, formattedDate));

    final symbol = ref.watch(currencySymbolProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                "Analysis: ${widget.item.itemName}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Controls
              Row(
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
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              if (isRangeMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          // Start of week (Monday)
                          final start = now.subtract(
                            Duration(days: now.weekday - 1),
                          );
                          setState(() {
                            selectedRange = DateTimeRange(
                              start: start,
                              end: now,
                            );
                          });
                        },
                        child: const Text("This Week"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final start = DateTime(now.year, now.month, 1);
                          setState(() {
                            selectedRange = DateTimeRange(
                              start: start,
                              end: now,
                            );
                          });
                        },
                        child: const Text("This Month"),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              statsAsync.when(
                data: (data) {
                  final totalSales = data['totalSales'] as double;
                  final totalQty = data['totalQty'] as int;
                  final chartData = isRangeMode
                      ? data['dailyData'] as List<Map<String, dynamic>>
                      : data['hourlyData'] as List<Map<String, dynamic>>;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              "Sales",
                              "$symbol${totalSales.toStringAsFixed(2)}",
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _MetricCard(
                              "Quantity",
                              totalQty.toString(),
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < chartData.length) {
                                      final item = chartData[value.toInt()];
                                      if (isRangeMode) {
                                        // date
                                        final d = DateTime.tryParse(
                                          item['date'],
                                        );
                                        return Text(
                                          DateFormat('MM-dd').format(d!),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      } else {
                                        return Text(
                                          item['hour'],
                                          style: const TextStyle(fontSize: 10),
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
                            gridData: FlGridData(show: false),
                            barGroups: List.generate(chartData.length, (index) {
                              final item = chartData[index];
                              final qty =
                                  (item['qty'] as num?)?.toDouble() ?? 0.0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: qty,
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
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text("Error: $e"),
              ),
            ],
          ),
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
