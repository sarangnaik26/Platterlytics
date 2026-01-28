class Category {
  final int? id;
  final String name;
  final int color;
  final int priority;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color, 'priority': priority};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int,
      priority: map['priority'] as int,
    );
  }
}
