class MenuPrice {
  final int? id;
  final int? menuId;
  final String unit;
  final double price;

  MenuPrice({this.id, this.menuId, required this.unit, required this.price});

  Map<String, dynamic> toMap() {
    return {'id': id, 'menu_id': menuId, 'unit': unit, 'price': price};
  }

  factory MenuPrice.fromMap(Map<String, dynamic> map) {
    return MenuPrice(
      id: map['id'] as int?,
      menuId: map['menu_id'] as int?,
      unit: map['unit'] as String,
      price: (map['price'] as num).toDouble(),
    );
  }
}

class MenuItem {
  final int? menuId; // Corresponds to menu_id
  final String itemName;
  final int categoryId;
  final List<MenuPrice> prices;

  MenuItem({
    this.menuId,
    required this.itemName,
    required this.categoryId,
    this.prices = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'menu_id': menuId,
      'item_name': itemName,
      'category_id': categoryId,
    };
  }

  factory MenuItem.fromMap(
    Map<String, dynamic> map, {
    List<MenuPrice> prices = const [],
  }) {
    return MenuItem(
      menuId: map['menu_id'] as int?,
      itemName: map['item_name'] as String,
      categoryId: map['category_id'] as int,
      prices: prices,
    );
  }

  MenuItem copyWith({
    int? menuId,
    String? itemName,
    int? categoryId,
    List<MenuPrice>? prices,
  }) {
    return MenuItem(
      menuId: menuId ?? this.menuId,
      itemName: itemName ?? this.itemName,
      categoryId: categoryId ?? this.categoryId,
      prices: prices ?? this.prices,
    );
  }
}
