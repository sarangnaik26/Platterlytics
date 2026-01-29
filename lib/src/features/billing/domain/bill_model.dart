class BillItem {
  final int? id;
  final int? billId;
  final int menuId;
  final String itemName; // Snapshot of name
  final String unit;
  final int quantity;
  final double price; // Snapshot of price
  final double totalItemPrice;

  BillItem({
    this.id,
    this.billId,
    required this.menuId,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.totalItemPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'menu_id': menuId,
      'item_name': itemName,
      'unit': unit,
      'quantity': quantity,
      'price': price,
      'total_item_price': totalItemPrice,
    };
  }
}

class Bill {
  final int? billId;
  final double totalPrice;
  final String date;
  final String time;
  final List<BillItem> items;

  Bill({
    this.billId,
    required this.totalPrice,
    required this.date,
    required this.time,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'bill_id': billId,
      'total_price': totalPrice,
      'date': date,
      'time': time,
    };
  }

  Bill copyWith({
    int? billId,
    double? totalPrice,
    String? date,
    String? time,
    List<BillItem>? items,
  }) {
    return Bill(
      billId: billId ?? this.billId,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
      time: time ?? this.time,
      items: items ?? this.items,
    );
  }
}
