import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/bill_model.dart';
import '../../menu/domain/menu_item.dart';

part 'cart_provider.g.dart';

@riverpod
class Cart extends _$Cart {
  @override
  List<BillItem> build() {
    return [];
  }

  void addItem({
    required MenuItem menuItem,
    required MenuPrice price,
    required double quantity,
  }) {
    // Check if item with same menuId and unit exists
    final existingIndex = state.indexWhere(
      (item) => item.menuId == menuItem.menuId && item.unit == price.unit,
    );

    if (existingIndex != -1) {
      // Update quantity
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      final updatedItem = BillItem(
        id: existingItem.id,
        billId: existingItem.billId,
        menuId: existingItem.menuId,
        itemName: existingItem.itemName,
        unit: existingItem.unit,
        quantity: newQuantity,
        price: existingItem.price,
        totalItemPrice: existingItem.price * newQuantity,
      );

      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Add new
      final newItem = BillItem(
        menuId: menuItem.menuId!,
        itemName: menuItem.itemName,
        unit: price.unit,
        quantity: quantity,
        price: price.price,
        totalItemPrice: price.price * quantity,
      );
      state = [...state, newItem];
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < state.length) {
      final newState = [...state];
      newState.removeAt(index);
      state = newState;
    }
  }

  void updateQuantity(int index, double quantity) {
    if (index >= 0 && index < state.length) {
      final item = state[index];
      if (quantity <= 0) {
        removeItem(index);
        return;
      }

      final updatedItem = BillItem(
        id: item.id,
        billId: item.billId,
        menuId: item.menuId,
        itemName: item.itemName,
        unit: item.unit,
        quantity: quantity,
        price: item.price,
        totalItemPrice: item.price * quantity,
      );

      final newState = [...state];
      newState[index] = updatedItem;
      state = newState;
    }
  }

  void clear() {
    state = [];
  }
}

@riverpod
double cartTotal(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalItemPrice);
}
