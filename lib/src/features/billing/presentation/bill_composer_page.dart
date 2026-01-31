import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/presentation/bill_settings_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../menu/domain/category.dart';
import '../../menu/domain/menu_item.dart';
import '../../menu/presentation/menu_providers.dart';
import '../data/bill_repository.dart';
import '../domain/bill_model.dart';
import 'cart_provider.dart';
import 'bill_success_view.dart';

class BillComposerPage extends ConsumerStatefulWidget {
  const BillComposerPage({super.key});

  @override
  ConsumerState<BillComposerPage> createState() => _BillComposerPageState();
}

class _BillComposerPageState extends ConsumerState<BillComposerPage> {
  int? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartTotalValue = ref.watch(cartTotalProvider);
    final cartItems = ref.watch(cartProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("New Bill")),
      body: Column(
        children: [
          // Categories and Search (Similar to MenuPage)
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty)
                  return const Center(child: Text("No Items"));

                return Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search items...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                    // Search and Chips
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategoryId == category.id;
                          return ChoiceChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected
                                    ? category.id
                                    : null;
                              });
                            },
                            selectedColor: Color(
                              category.color,
                            ).withOpacity(0.2), // Deprecated?
                            labelStyle: TextStyle(
                              color: isSelected ? Color(category.color) : null,
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    Expanded(
                      child: _BillingContent(
                        categories: categories,
                        selectedCategoryId: _selectedCategoryId,
                        searchQuery: _searchQuery,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),

          // Bottom Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showCartSheet(context);
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: Text("Bill Items (${cartItems.length})"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () async {
                            // Done - Finalize
                            final now = DateTime.now();
                            final bill = Bill(
                              totalPrice: cartTotalValue,
                              date: DateFormat('yyyy-MM-dd').format(now),
                              time: DateFormat('HH:mm').format(now),
                              items: cartItems,
                            );

                            try {
                              final billId = await ref
                                  .read(billRepositoryProvider)
                                  .createBill(bill);

                              if (context.mounted) {
                                ref.read(cartProvider.notifier).clear();
                                final savedBill = bill.copyWith(billId: billId);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BillSuccessView(bill: savedBill),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                            }
                          },
                    child: Text(
                      "Done ($symbol${cartTotalValue.toStringAsFixed(2)})",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const CartBottomSheet(),
    );
  }
}

class _BillingContent extends ConsumerWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final String searchQuery;

  const _BillingContent({
    required this.categories,
    this.selectedCategoryId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Improve: Instead of filtering, we just scroll to the category (TODO if ScrollController added)
    // For now, per user request, we do NOT filter them out.
    // They wanted "other categories to appear below", i.e. show all.
    final displayCategories = categories;

    // Sorting: If selected, maybe move to top?
    // User said: "that category comes on top and rest all categories disapear, but i want other categories to appear below"
    // So let's sort the selected index to 0, and others follow.
    if (selectedCategoryId != null) {
      displayCategories.sort((a, b) {
        if (a.id == selectedCategoryId) return -1;
        if (b.id == selectedCategoryId) return 1;
        return a.priority.compareTo(b.priority);
      });
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        return BillingCategoryCard(
          category: displayCategories[index],
          searchQuery: searchQuery,
        );
      },
    );
  }
}

class BillingCategoryCard extends ConsumerWidget {
  final Category category;
  final String searchQuery;

  const BillingCategoryCard({
    super.key,
    required this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(
      menuItemsProvider(categoryId: category.id),
    );
    final symbol = ref.watch(currencySymbolProvider);

    return menuItemsAsync.when(
      data: (items) {
        final filteredItems = items.where((item) {
          if (searchQuery.isEmpty) return true;
          return item.itemName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        }).toList();

        if (filteredItems.isEmpty && searchQuery.isNotEmpty)
          return const SizedBox.shrink();

        // Even if items is empty (e.g. empty category without search), we might want to hide it in billing to avoid clutter
        if (items.isEmpty && searchQuery.isEmpty)
          return const SizedBox.shrink();

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(item.itemName),
                    trailing: ElevatedButton(
                      onPressed: () => _showAddItemDialog(context, ref, item),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Icon(Icons.add),
                    ),
                    subtitle: Text(
                      item.prices
                          .map((p) => "${p.unit}: $symbol${p.price}")
                          .join(", "),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox(),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, MenuItem item) {
    // If multiple prices, let user select. Default to first.
    MenuPrice selectedPrice = item.prices.first;
    final quantityController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add ${item.itemName}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MenuPrice>(
                    value: selectedPrice,
                    decoration: const InputDecoration(labelText: "Unit"),
                    items: item.prices.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          "${p.unit} - ${ref.read(currencySymbolProvider)}${p.price}",
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedPrice = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(quantityController.text) ?? 1;
                    if (qty > 0) {
                      ref
                          .read(cartProvider.notifier)
                          .addItem(
                            menuItem: item,
                            price: selectedPrice,
                            quantity: qty,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Column(
      children: [
        AppBar(
          title: const Text("Bill Items"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        if (cartItems.isEmpty)
          const Expanded(child: Center(child: Text("Cart is Empty"))),
        if (cartItems.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                    "${item.quantity} x ${item.unit} @ $symbol${item.price}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$symbol${item.totalItemPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(cartProvider.notifier).removeItem(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
