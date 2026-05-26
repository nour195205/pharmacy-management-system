import 'package:desktop/features/medicines/domain/entities/medicine.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.name,
    required super.category,
    super.description,
    super.barcode,
    required super.unit,
    required super.price,
    super.reorderLevel,
    super.isActive = true,
    super.isSynced = false,
  });

  // From database map (SQLite)
  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      barcode: map['barcode'] as String?,
      unit: map['unit'] as String,
      price: (map['price'] as num).toInt(),
      reorderLevel: map['reorder_level'] as String?,
      isActive: (map['is_active'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  // To database map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'barcode': barcode,
      'unit': unit,
      'price': price,
      'reorder_level': reorderLevel,
      'is_active': isActive ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // From remote JSON (Laravel REST API)
  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      category: json['category'] ?? 'عام',
      description: json['description'] as String?,
      barcode: json['barcode'] as String?,
      unit: json['unit'] ?? 'علبه',
      price: (json['price'] as num?)?.toInt() ?? 0,
      reorderLevel: json['reorder_level']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isSynced: true, // If we got it from the server, it is synced
    );
  }

  // To remote JSON (Laravel REST API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description ?? '',
      'barcode': barcode ?? '',
      'unit': unit,
      'price': price,
      'reorder_level': reorderLevel ?? '10', // Default reorder level if null
      'is_active': isActive ? 1 : 0,
    };
  }

  // Cast entity to model helper
  factory MedicineModel.fromEntity(Medicine medicine) {
    return MedicineModel(
      id: medicine.id,
      name: medicine.name,
      category: medicine.category,
      description: medicine.description,
      barcode: medicine.barcode,
      unit: medicine.unit,
      price: medicine.price,
      reorderLevel: medicine.reorderLevel,
      isActive: medicine.isActive,
      isSynced: medicine.isSynced,
    );
  }
}
