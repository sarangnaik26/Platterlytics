import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/category.dart';
import '../domain/menu_item.dart';
import 'menu_providers.dart';
import '../../settings/presentation/bill_settings_provider.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  int? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Management")),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Menu Created Yet"),
                  ElevatedButton(
                    onPressed: _showAddCategoryDialog,
                    child: const Text("Create 'Menu' Category"),
                  ),
                ],
              ),
            );
          }

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

              // Category Selector
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1, // +1 for Add Button
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return ActionChip(
                        avatar: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Category"),
                        backgroundColor: AppColors.primary,
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed: _showAddCategoryDialog,
                      );
                    }
                    final category = categories[index];

                    return ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                      selectedColor: Color(
                        category.color,
                      ).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _selectedCategoryId == category.id
                            ? Color(category.color)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: _MenuContent(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  searchQuery: _searchQuery,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add Item to selected Category or prompt
          if (_selectedCategoryId != null) {
            _showAddItemDialog(_selectedCategoryId!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a category first")),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    // Implementation
    showDialog(context: context, builder: (_) => const AddCategoryDialog());
  }

  void _showAddItemDialog(int categoryId) {
    showDialog(
      context: context,
      builder: (_) => MenuItemDialog(categoryId: categoryId),
    );
  }
}

class _MenuContent extends ConsumerWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final String searchQuery;

  const _MenuContent({
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
        final category = displayCategories[index];
        return CategoryCard(category: category, searchQuery: searchQuery);
      },
    );
  }
}

class CategoryCard extends ConsumerWidget {
  final Category category;
  final String searchQuery;

  const CategoryCard({
    super.key,
    required this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(
      menuItemsProvider(categoryId: category.id),
    );

    return menuItemsAsync.when(
      data: (items) {
        final filteredItems = items.where((item) {
          if (searchQuery.isEmpty) return true;
          return item.itemName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        }).toList();

        if (filteredItems.isEmpty && searchQuery.isNotEmpty) {
          return const SizedBox.shrink(); // Hide category if no matches
        }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(category.color).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(category.color),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Color(category.color),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              MenuItemDialog(categoryId: category.id!),
                        );
                      },
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text("Rename"),
                        ),
                        const PopupMenuItem(
                          value: 'color',
                          child: Text("Color Code"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          ref
                              .read(categoriesProvider.notifier)
                              .delete(category.id!);
                        } else if (value == 'rename') {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                RenameCategoryDialog(category: category),
                          );
                        } else if (value == 'color') {
                          showDialog(
                            context: context,
                            builder: (context) => _ColorPickerDialog(
                              category: category,
                              onColorSelected: (color) {
                                final updated = Category(
                                  id: category.id,
                                  name: category.name,
                                  color: color.toARGB32(),
                                  priority: category.priority,
                                );
                                ref
                                    .read(categoriesProvider.notifier)
                                    .updateCategory(updated);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (filteredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No items"),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Consumer(
                        builder: (context, ref, child) {
                          return Text(
                            item.prices
                                .map((p) {
                                  final formatted = ref.watch(
                                    formatCurrencyProvider(p.price),
                                  );
                                  return "${p.unit}: $formatted";
                                })
                                .join(", "),
                          );
                        },
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (_) => MenuItemDialog(
                                categoryId: category.id!,
                                itemToEdit: item,
                              ),
                            );
                          } else if (value == 'delete') {
                            showConfirmDialog(
                              context: context,
                              title: "Delete Item",
                              content:
                                  "Are you sure you want to delete '${item.itemName}'?",
                              onConfirm: () {
                                ref
                                    .read(menuControllerProvider.notifier)
                                    .deleteMenuItem(item.menuId!);
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, s) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("Error loading items: $e"),
        ),
      ),
    );
  }
}

// Dialogs (Placeholders for brevity, should be implemented properly)
class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final Color _selectedColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Category"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          // Color picker placeholder
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            if (name.isNotEmpty) {
              ref
                  .read(categoriesProvider.notifier)
                  .add(
                    Category(
                      name: name,
                      color: _selectedColor.toARGB32(),
                      priority: 1,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class MenuItemDialog extends ConsumerStatefulWidget {
  final int categoryId;
  final MenuItem? itemToEdit;
  const MenuItemDialog({super.key, required this.categoryId, this.itemToEdit});

  @override
  ConsumerState<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends ConsumerState<MenuItemDialog> {
  final _nameController = TextEditingController();

  // List to hold the controllers for each price entry
  final List<Map<String, dynamic>> _priceEntries = [];

  final List<String> _unitOptions = [
    'Piece',
    'Plate',
    'Kg',
    'Liter',
    'Glass',
    'Bottle',
    'Slice',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _nameController.text = widget.itemToEdit!.itemName;
      for (var price in widget.itemToEdit!.prices) {
        _priceEntries.add({
          'unit': price.unit,
          'priceController': TextEditingController(
            text: price.price.toString(),
          ),
        });
      }
      if (_priceEntries.isEmpty) {
        _addPriceEntry();
      }
    } else {
      _addPriceEntry();
    }
  }

  void _addPriceEntry() {
    setState(() {
      _priceEntries.add({
        'unit': _unitOptions.first, // Default unit
        'priceController': TextEditingController(),
      });
    });
  }

  void _removePriceEntry(int index) {
    if (_priceEntries.length > 1) {
      setState(() {
        _priceEntries[index]['priceController'].dispose();
        _priceEntries.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var entry in _priceEntries) {
      entry['priceController'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.itemToEdit != null ? "Edit Item" : "Add Item"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Prices & Units",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._priceEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        initialValue: data['unit'],
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Unit",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: _unitOptions.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                unit,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              data['unit'] = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: data['priceController'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Price",
                          prefixText: "${ref.watch(currencySymbolProvider)} ",
                          prefixStyle: const TextStyle(fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 22,
                      ),
                      onPressed: _priceEntries.length > 1
                          ? () => _removePriceEntry(index)
                          : null,
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addPriceEntry,
              icon: const Icon(Icons.add),
              label: const Text("Add Another Price"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final List<MenuPrice> prices = [];
              for (var entry in _priceEntries) {
                final priceText = entry['priceController'].text;
                if (priceText.isNotEmpty) {
                  final price = double.tryParse(priceText) ?? 0.0;
                  prices.add(MenuPrice(unit: entry['unit'], price: price));
                }
              }

              if (prices.isNotEmpty) {
                final newItem = MenuItem(
                  menuId: widget.itemToEdit?.menuId,
                  itemName: _nameController.text,
                  categoryId: widget.categoryId,
                  prices: prices,
                );

                if (widget.itemToEdit != null) {
                  ref
                      .read(menuControllerProvider.notifier)
                      .updateMenuItem(newItem);
                } else {
                  ref
                      .read(menuControllerProvider.notifier)
                      .addMenuItem(newItem);
                }
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter at least one valid price"),
                  ),
                );
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

class RenameCategoryDialog extends ConsumerStatefulWidget {
  final Category category;
  const RenameCategoryDialog({super.key, required this.category});

  @override
  ConsumerState<RenameCategoryDialog> createState() =>
      _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends ConsumerState<RenameCategoryDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = Color(widget.category.color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rename Category"),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: "Category Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            if (name.isNotEmpty) {
              final updated = Category(
                id: widget.category.id,
                name: name,
                color: _selectedColor.toARGB32(),
                priority: widget.category.priority,
              );
              ref.read(categoriesProvider.notifier).updateCategory(updated);
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

void showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  final Category category;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.category,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  final List<Color> _colors = [
    const Color(0xFFEF5350), // Red
    const Color(0xFFEC407A), // Pink
    const Color(0xFFAB47BC), // Purple
    const Color(0xFF7E57C2), // Deep Purple
    const Color(0xFF5C6BC0), // Indigo
    const Color(0xFF42A5F5), // Blue
    const Color(0xFF26A69A), // Teal
    const Color(0xFF66BB6A), // Green
    const Color(0xFFFFCA28), // Amber
    const Color(0xFFFFA726), // Orange
    const Color(0xFF8D6E63), // Brown
    const Color(0xFF78909C), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = Color(widget.category.color);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose Color",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                final isSelected =
                    _selectedColor.toARGB32() == color.toARGB32();
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onColorSelected(_selectedColor);
                  Navigator.pop(context);
                },
                child: const Text("Set Color"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
