import 'package:desktop/features/sales/domain/entities/sales_return_item.dart';

class SalesReturnItemModel extends SalesReturnItem {
  const SalesReturnItemModel({
    required super.id,
    required super.salesReturnId,
    required super.batchId,
    super.batchNumber,
    super.medicineName,
    required super.quantity,
    required super.sellingPrice,
    required super.total,
  });

  factory SalesReturnItemModel.fromMap(Map<String, dynamic> map) {
    return SalesReturnItemModel(
      id: map['id']?.toString() ?? '',
      salesReturnId: map['sales_return_id']?.toString() ?? '',
      batchId: map['batch_id']?.toString() ?? '',
      batchNumber: map['batch_number']?.toString(),
      medicineName: map['medicine_name']?.toString(),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sales_return_id': salesReturnId,
      'batch_id': batchId,
      'quantity': quantity,
      'selling_price': sellingPrice,
      'total': total,
    };
  }

  factory SalesReturnItemModel.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'] as Map<String, dynamic>?;
    final medicine = batch?['medicine'] as Map<String, dynamic>?;

    return SalesReturnItemModel(
      id: json['id']?.toString() ?? '',
      salesReturnId: json['sales_return_id']?.toString() ?? '',
      batchId: batch?['id']?.toString() ?? '',
      batchNumber: batch?['batch_number']?.toString(),
      medicineName: medicine?['name']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
