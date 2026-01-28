import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/category.dart';
import '../domain/menu_item.dart';
import 'menu_providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  int? _selectedCategoryId;

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
                    // Implement Search Filter
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

                    // Default select first if null? Or "All"?
                    // Logic: If _selectedCategoryId is null, maybe show all?
                    // Let's assume selecting a category filters the view.

                    return ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                      selectedColor: Color(category.color).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedCategoryId == category.id
                            ? Color(category.color)
                            : AppColors.textPrimary,
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
      builder: (_) => AddMenuItemDialog(categoryId: categoryId),
    );
  }
}

class _MenuContent extends ConsumerWidget {
  final List<Category> categories;
  final int? selectedCategoryId;

  const _MenuContent({required this.categories, this.selectedCategoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If selectedCategoryId is NOT null, show that category card.
    // If null, show ALL.

    // If selectedCategoryId is NOT null, selected category comes first.
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
        return CategoryCard(category: category);
      },
    );
  }
}

class CategoryCard extends ConsumerWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(category.color).withOpacity(0.1),
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
                          AddMenuItemDialog(categoryId: category.id!),
                    );
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'rename', child: Text("Rename")),
                    const PopupMenuItem(
                      value: 'priority',
                      child: Text("Set Priority"),
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
                    }
                    // Handle others
                  },
                ),
              ],
            ),
          ),
          menuItemsAsync.when(
            data: (items) {
              if (items.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No items"),
                );
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.itemName),
                    subtitle: Text(
                      item.prices
                          .map((p) => "${p.unit}: ${p.price}")
                          .join(", "),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Edit/Delete Item
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Error loading items: $e"),
            ),
          ),
        ],
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
  Color _selectedColor = AppColors.primary;

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
                      color: _selectedColor.value,
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

class AddMenuItemDialog extends ConsumerStatefulWidget {
  final int categoryId;
  const AddMenuItemDialog({super.key, required this.categoryId});

  @override
  ConsumerState<AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends ConsumerState<AddMenuItemDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: "Plate");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Item Name"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: "Unit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
              ),
            ],
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
            if (_nameController.text.isNotEmpty &&
                _priceController.text.isNotEmpty) {
              final price = double.tryParse(_priceController.text) ?? 0.0;
              final newItem = MenuItem(
                itemName: _nameController.text,
                categoryId: widget.categoryId,
                prices: [MenuPrice(unit: _unitController.text, price: price)],
              );
              ref.read(menuControllerProvider.notifier).addMenuItem(newItem);
              Navigator.pop(context);
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
                color: _selectedColor.value,
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
