class Medicine {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? barcode;
  final String unit; // 'شريط', 'علبه', 'زجاجه'
  final int price;
  final String? reorderLevel;
  final bool isActive;
  final bool isSynced;

  const Medicine({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.barcode,
    required this.unit,
    required this.price,
    this.reorderLevel,
    this.isActive = true,
    this.isSynced = false,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? barcode,
    String? unit,
    int? price,
    String? reorderLevel,
    bool? isActive,
    bool? isSynced,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      isActive: isActive ?? this.isActive,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
