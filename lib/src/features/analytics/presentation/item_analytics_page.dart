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
import '../../settings/presentation/settings_providers.dart';
import '../../settings/presentation/date_format_provider.dart';
import '../../../core/utils/formatters.dart';

enum ItemAnalyticsMode { daily, range, weekday }

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
                      selectedColor: Color(
                        category.color,
                      ).withValues(alpha: 0.2),
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
              color: Color(category.color).withValues(alpha: 0.1),
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
  ItemAnalyticsMode _selectedMode = ItemAnalyticsMode.range;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange;
  int _selectedWeekday = DateTime.now().weekday;

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
      case ItemAnalyticsMode.daily:
        statsAsync = ref.watch(
          itemDailyStatsProvider(widget.item.menuId!, formattedDate),
        );
        break;
      case ItemAnalyticsMode.range:
        statsAsync = ref.watch(
          itemRangeStatsProvider(
            widget.item.menuId!,
            formattedStart,
            formattedEnd,
          ),
        );
        break;
      case ItemAnalyticsMode.weekday:
        if (_selectedWeekday == 0) {
          statsAsync = ref.watch(
            itemWeeklyStatsProvider(widget.item.menuId!, weeksBack),
          );
        } else {
          statsAsync = ref.watch(
            itemWeekdayStatsProvider(
              widget.item.menuId!,
              weeksBack,
              _selectedWeekday,
            ),
          );
        }
        break;
    }

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
              Column(
                children: [
                  SegmentedButton<ItemAnalyticsMode>(
                    segments: const [
                      ButtonSegment(
                        value: ItemAnalyticsMode.daily,
                        label: FittedBox(child: Text("Daily")),
                      ),
                      ButtonSegment(
                        value: ItemAnalyticsMode.range,
                        label: FittedBox(child: Text("Range")),
                      ),
                      ButtonSegment(
                        value: ItemAnalyticsMode.weekday,
                        label: FittedBox(child: Text("Weekday")),
                      ),
                    ],
                    selected: {_selectedMode},
                    onSelectionChanged: (Set<ItemAnalyticsMode> newSelection) {
                      setState(() {
                        _selectedMode = newSelection.first;
                      });
                    },
                  ),
                  if (_selectedMode == ItemAnalyticsMode.weekday) ...[
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(8, (index) {
                          // 0=Week, 1=Mon...
                          final dayIndex = index;
                          final isSelected = _selectedWeekday == dayIndex;
                          const labels = [
                            "Week", // 0
                            "Mon",
                            "Tue",
                            "Wed",
                            "Thu",
                            "Fri",
                            "Sat",
                            "Sun",
                          ];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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

              const SizedBox(height: 8),
              if (_selectedMode == ItemAnalyticsMode.daily)
                Row(
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
              if (_selectedMode == ItemAnalyticsMode.range) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          setState(() {
                            selectedRange = DateTimeRange(
                              start: now.subtract(const Duration(days: 6)),
                              end: now,
                            );
                          });
                        },
                        child: const Text("Last 7 Days"),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "${formatDate(selectedRange!.start)} - ${formatDate(selectedRange!.end)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              statsAsync!.when(
                data: (data) {
                  if (_selectedMode == ItemAnalyticsMode.weekday) {
                    return _buildWeekdayContent(data, weeksBack);
                  } else {
                    return _buildStandardContent(data);
                  }
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

  Widget _buildStandardContent(Map<String, dynamic> data) {
    final totalSales = (data['totalSales'] as num).toDouble(); // mapped from DB
    final totalQty = (data['totalQty'] as num).toDouble();
    final chartData = _selectedMode == ItemAnalyticsMode.range
        ? data['dailyData'] as List<Map<String, dynamic>>
        : data['hourlyData'] as List<Map<String, dynamic>>;

    final totalQtyByUnit = data['totalQtyByUnit'] as Map<String, double>? ?? {};
    final units = data['units'] as List<String>? ?? [];

    // Calculate maxQty for headroom (sum of all units in a slot)
    double maxQty = 0;
    if (chartData.isNotEmpty) {
      maxQty = chartData
          .map((e) {
            // Requirement: "show multiple bars, each for a unit". So side-by-side.
            // We need the max of any single unit in any slot.
            double maxUnitInSlot = 0;
            for (var unit in units) {
              final q = (e[unit] as num?)?.toDouble() ?? 0.0;
              if (q > maxUnitInSlot) maxUnitInSlot = q;
            }
            return maxUnitInSlot;
          })
          .reduce((a, b) => a > b ? a : b);
    }
    if (maxQty == 0) maxQty = 5;

    // Define colors for units
    // We can use a predefined list or generate them.
    final List<Color> unitColorsPalette = [
      AppColors.primary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    final Map<String, Color> unitColors = {};
    for (int i = 0; i < units.length; i++) {
      unitColors[units[i]] = unitColorsPalette[i % unitColorsPalette.length];
    }

    String qtyBreakdown = formatQuantity(totalQty);
    if (totalQtyByUnit.isNotEmpty) {
      final parts = <String>[];
      totalQtyByUnit.forEach((unit, qty) {
        parts.add("${formatQuantity(qty)} $unit");
      });
      qtyBreakdown = parts.join(", ");
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  return _MetricCard(
                    "Sales",
                    ref.watch(formatCurrencyProvider(totalSales)),
                    Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                "Quantity",
                qtyBreakdown, // Show breakdown query
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Legend if multiple units
        if (units.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: units.map((u) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: unitColors[u],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(u, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ),
        SizedBox(
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: (chartData.length * 50.0).clamp(
                MediaQuery.of(context).size.width - 32,
                double.infinity,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BarChart(
                BarChartData(
                  maxY: maxQty * 1.25,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < chartData.length) {
                            final item = chartData[value.toInt()];
                            if (_selectedMode == ItemAnalyticsMode.range) {
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
                                    final parts = formatted.split('/');
                                    String displayLabel;
                                    if (parts.length >= 2) {
                                      if (formatted.startsWith(
                                        RegExp(r'\d{4}'),
                                      )) {
                                        displayLabel =
                                            '${parts[1]}/${parts[2]}';
                                      } else {
                                        displayLabel =
                                            '${parts[0]}/${parts[1]}';
                                      }
                                    } else {
                                      displayLabel = formatted;
                                    }
                                    return Text(
                                      displayLabel,
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  item['hour'],
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
                    enabled: false, // Disable touch since we show always
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 2,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY == 0) return null;
                        return BarTooltipItem(
                          formatQuantity(rod.toY),
                          TextStyle(
                            color: rod.color ?? AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(chartData.length, (index) {
                    final item = chartData[index];

                    // Create a rod for each unit
                    List<BarChartRodData> rods = [];
                    // Collect indices to show tooltip for
                    List<int> showingTooltipIndicators = [];

                    for (int i = 0; i < units.length; i++) {
                      final u = units[i];
                      final qty = (item[u] as num?)?.toDouble() ?? 0.0;
                      if (qty > 0 || units.length == 1) {
                        rods.add(
                          BarChartRodData(
                            toY: qty,
                            color: unitColors[u],
                            width: units.length > 1
                                ? 8
                                : 16, // Thinner bars if multiple
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                        if (qty > 0) {
                          showingTooltipIndicators.add(rods.length - 1);
                        }
                      }
                    }

                    // If no rods (no sales), still return group
                    return BarChartGroupData(
                      x: index,
                      barRods: rods,
                      barsSpace: 2,
                      showingTooltipIndicators: showingTooltipIndicators,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
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

    final avgQty = (data['avgQty'] as num).toDouble();
    final latestSnapshot = data['latest'] as Map<String, dynamic>?;
    final trend = data['trend'] as Map<String, dynamic>;
    final contribution = (data['contribution'] as num).toDouble();
    final history = data['history'] as List<dynamic>;
    final peakDay = data['peakDay'] as String;

    final units = (data['units'] as List?)?.cast<String>() ?? [];
    // Calculate avg qty per unit
    final Map<String, double> avgQtyByUnit = {};
    if (history.isNotEmpty && units.isNotEmpty) {
      for (var unit in units) {
        double sum = 0;
        for (var day in history) {
          sum += (day[unit] as num?)?.toDouble() ?? 0.0;
        }
        avgQtyByUnit[unit] = sum / history.length;
      }
    }

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

    // Calculate maxQty for headroom
    double maxQty = 0;
    if (history.isNotEmpty) {
      maxQty = history
          .map((e) {
            double maxUnitInSlot = 0;
            // Checks max of single unit if we break it down
            if (units.isNotEmpty) {
              for (var unit in units) {
                final q = (e[unit] as num?)?.toDouble() ?? 0.0;
                if (q > maxUnitInSlot) maxUnitInSlot = q;
              }
            } else {
              maxUnitInSlot = (e['qty'] as num).toDouble();
            }
            return maxUnitInSlot;
          })
          .reduce((a, b) => a > b ? a : b);
    }
    if (maxQty == 0) maxQty = 5; // Default if no data

    // Define colors for units (Consistent with standard view)
    final List<Color> unitColorsPalette = [
      AppColors.primary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    final Map<String, Color> unitColors = {};
    for (int i = 0; i < units.length; i++) {
      unitColors[units[i]] = unitColorsPalette[i % unitColorsPalette.length];
    }

    String avgQtyText = formatQuantity(avgQty);
    if (avgQtyByUnit.isNotEmpty) {
      final parts = <String>[];
      avgQtyByUnit.forEach((unit, qty) {
        parts.add("${formatQuantity(qty)} $unit");
      });
      avgQtyText = parts.join(", ");
    }

    final actualWeeks = data['totalWeeks'] ?? weeksBack;
    return Column(
      children: [
        Text(
          "${getDayName(_selectedWeekday)} Overview for ${widget.item.itemName}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          "Based on last $actualWeeks ${getDayName(_selectedWeekday)}s",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _MetricCard("Avg Quantity", avgQtyText, Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard("Peak Day", peakDay, Colors.orange)),
          ],
        ),
        const SizedBox(height: 16),

        // Trend
        Row(
          children: [
            Expanded(
              child: _TrendCard(
                label: "Growth",
                value:
                    "${((trend['growth'] as double) * 100).toStringAsFixed(1)}%",
                subLabel: "vs prev week",
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
                subLabel: "stability",
                color: Colors.blueGrey,
                icon: Icons.show_chart,
              ),
            ),
          ],
        ),
        // Contribution
        if (_selectedWeekday != 0)
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

        if (_selectedWeekday != 0 && peakDay != "N/A") ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text("Peak Day"),
              subtitle: Text(
                "Most ${widget.item.itemName} are sold on $peakDay",
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        const Text(
          "Selling Quantity History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Legend if multiple units
        if (units.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: units.map((u) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: unitColors[u],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(u, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: (history.length * 60.0).clamp(
                MediaQuery.of(context).size.width - 32,
                double.infinity,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BarChart(
                BarChartData(
                  maxY: maxQty * 1.25, // 25% headroom
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < history.length) {
                            final item = history[value.toInt()];

                            // For Weekly View: Display Week Range
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

                            // For Weekday View or fallback
                            final dateStr =
                                item['date'] as String? ??
                                item['start_date'] as String?;
                            final d = dateStr != null
                                ? DateTime.tryParse(dateStr)
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Consumer(
                                builder: (context, ref, _) {
                                  if (d == null) return const Text('');
                                  final formatDate = ref.watch(
                                    formatDateProvider,
                                  );
                                  final formatted = formatDate(d);
                                  final parts = formatted.split('/');
                                  // Shorten date for chart
                                  String label = formatted;
                                  if (parts.length >= 2) {
                                    if (formatted.startsWith(
                                      RegExp(r'\d{4}'),
                                    )) {
                                      label = '${parts[1]}/${parts[2]}';
                                    } else {
                                      label = '${parts[0]}/${parts[1]}';
                                    }
                                  }
                                  return Text(
                                    label,
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
                        if (rod.toY == 0) return null;
                        return BarTooltipItem(
                          formatQuantity(rod.toY),
                          TextStyle(
                            color: rod.color ?? AppColors.primary,
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

                    List<BarChartRodData> rods = [];
                    List<int> showingTooltipIndicators = [];

                    if (units.isNotEmpty) {
                      for (int i = 0; i < units.length; i++) {
                        final u = units[i];
                        final qty = (item[u] as num?)?.toDouble() ?? 0.0;
                        if (qty > 0 || units.length == 1) {
                          rods.add(
                            BarChartRodData(
                              toY: qty,
                              color: unitColors[u],
                              width: units.length > 1 ? 8 : 16,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                          if (qty > 0) {
                            showingTooltipIndicators.add(rods.length - 1);
                          }
                        }
                      }
                    } else {
                      // Fallback for no units logic (legacy data?)
                      final qty = (item['qty'] as num).toDouble();
                      rods.add(
                        BarChartRodData(
                          toY: qty,
                          color: AppColors.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                      if (qty > 0) showingTooltipIndicators.add(0);
                    }

                    return BarChartGroupData(
                      x: index,
                      barRods: rods,
                      barsSpace: 2,
                      showingTooltipIndicators: showingTooltipIndicators,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (latestSnapshot != null) ...[
          const Text(
            "Latest Co-Selling Items",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (latestSnapshot['coSelling'] != null)
            ...(latestSnapshot['coSelling'] as List).map(
              (i) => ListTile(
                dense: true,
                title: Text(i['item_name']),
                trailing: Text("${i['frequency']} times"),
                leading: const Icon(Icons.link, size: 16),
              ),
            ),
          if ((latestSnapshot['coSelling'] as List).isEmpty)
            const Text("No co-selling data."),
        ],
      ],
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subLabel,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
            style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
