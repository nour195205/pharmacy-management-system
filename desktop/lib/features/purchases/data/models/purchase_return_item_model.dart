import 'package:desktop/features/purchases/domain/entities/purchase_return_item.dart';

class PurchaseReturnItemModel extends PurchaseReturnItem {
  const PurchaseReturnItemModel({
    super.id,
    super.purchaseReturnId,
    required super.batchId,
    super.batchNumber,
    super.medicineName,
    required super.quantity,
    required super.purchasePrice,
    required super.total,
  });

  factory PurchaseReturnItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseReturnItemModel(
      id: map['id']?.toString(),
      purchaseReturnId: map['purchase_return_id']?.toString(),
      batchId: map['batch_id']?.toString() ?? '',
      batchNumber: map['batch_number']?.toString(),
      medicineName: map['medicine_name']?.toString(),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_return_id': purchaseReturnId,
      'batch_id': batchId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'total': total,
    };
  }

  factory PurchaseReturnItemModel.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'] as Map<String, dynamic>?;
    final medicine = batch?['medicine'] as Map<String, dynamic>?;

    return PurchaseReturnItemModel(
      id: json['id']?.toString(),
      batchId: batch?['id']?.toString() ?? '',
      batchNumber: batch?['batch_number']?.toString(),
      medicineName: medicine?['name']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'quantity': quantity,
    };
  }
}
