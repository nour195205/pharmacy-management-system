import 'package:desktop/features/inventory/domain/entities/batch.dart';

class BatchModel extends Batch {
  const BatchModel({
    required super.id,
    required super.medicineId,
    super.medicineName,
    required super.batchNumber,
    required super.manufactureDate,
    required super.expiryDate,
    required super.quantity,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.branchId,
    super.isSynced = false,
  });

  // From database map (SQLite) — includes joined medicine_name
  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] as String,
      medicineId: map['medicine_id'] as String,
      medicineName: map['medicine_name'] as String?,
      batchNumber: map['batch_number'] as String,
      manufactureDate: map['manufacture_date'] as String,
      expiryDate: map['expiry_date'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      purchasePrice: (map['purchase_price'] as num).toInt(),
      sellingPrice: (map['selling_price'] as num).toInt(),
      branchId: (map['branch_id'] as num).toInt(),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  // To database map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_id': medicineId,
      'batch_number': batchNumber,
      'manufacture_date': manufactureDate,
      'expiry_date': expiryDate,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'branch_id': branchId,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // From remote JSON (Laravel BatchResource)
  factory BatchModel.fromJson(Map<String, dynamic> json) {
    // Extract medicine name from nested object if available
    String? medName;
    String medId;
    if (json['medicine'] != null && json['medicine'] is Map) {
      medName = json['medicine']['name'] as String?;
      medId = json['medicine']['id'].toString();
    } else {
      medId = (json['medicine_id'] ?? '').toString();
    }

    // Extract branch_id from nested object if available
    int bId;
    if (json['branch'] != null && json['branch'] is Map) {
      bId = (json['branch']['id'] as num?)?.toInt() ?? 1;
    } else {
      bId = (json['branch_id'] as num?)?.toInt() ?? 1;
    }

    return BatchModel(
      id: json['id'].toString(),
      medicineId: medId,
      medicineName: medName,
      batchNumber: (json['batch_number'] ?? '').toString(),
      manufactureDate: (json['manufacture_date'] ?? '').toString(),
      expiryDate: (json['expiry_date'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchase_price'] as num?)?.toInt() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toInt() ?? 0,
      branchId: bId,
      isSynced: true, // Server data is always synced
    );
  }

  // To remote JSON (Laravel StoreBatchRequest)
  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'batch_number': batchNumber,
      'manufacture_date': manufactureDate,
      'expiry_date': expiryDate,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'branch_id': branchId,
    };
  }

  // Cast entity to model
  factory BatchModel.fromEntity(Batch batch) {
    return BatchModel(
      id: batch.id,
      medicineId: batch.medicineId,
      medicineName: batch.medicineName,
      batchNumber: batch.batchNumber,
      manufactureDate: batch.manufactureDate,
      expiryDate: batch.expiryDate,
      quantity: batch.quantity,
      purchasePrice: batch.purchasePrice,
      sellingPrice: batch.sellingPrice,
      branchId: batch.branchId,
      isSynced: batch.isSynced,
    );
  }
}
