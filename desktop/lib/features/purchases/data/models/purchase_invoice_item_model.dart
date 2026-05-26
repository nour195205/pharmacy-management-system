import 'package:desktop/features/purchases/domain/entities/purchase_invoice_item.dart';

class PurchaseInvoiceItemModel extends PurchaseInvoiceItem {
  const PurchaseInvoiceItemModel({
    super.id,
    super.purchaseInvoiceId,
    required super.medicineId,
    super.medicineName,
    super.batchId,
    super.batchNumber,
    required super.quantity,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.manufactureDate,
    required super.expiryDate,
  });

  factory PurchaseInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceItemModel(
      id: map['id']?.toString(),
      purchaseInvoiceId: map['purchase_invoice_id']?.toString(),
      medicineId: map['medicine_id']?.toString() ?? '',
      medicineName: map['medicine_name']?.toString(),
      batchId: map['batch_id']?.toString(),
      batchNumber: map['batch_number']?.toString(),
      quantity: (map['qty'] as num?)?.toInt() ?? 0,
      purchasePrice: (map['price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0, // may be missing if not joined
      manufactureDate: map['manufacture_date']?.toString() ?? '', // may be missing if not joined
      expiryDate: map['expiry_date']?.toString() ?? '', // may be missing if not joined
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_invoice_id': purchaseInvoiceId,
      'batch_id': batchId,
      'qty': quantity,
      'price': purchasePrice,
    };
  }

  factory PurchaseInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    // Handling remote JSON from PurchaseInvoiceItemResource
    final batch = json['batch'] as Map<String, dynamic>?;
    final medicine = batch?['medicine'] as Map<String, dynamic>?;

    return PurchaseInvoiceItemModel(
      id: json['id']?.toString(),
      medicineId: medicine?['id']?.toString() ?? '',
      medicineName: medicine?['name']?.toString(),
      batchId: batch?['id']?.toString(),
      batchNumber: batch?['batch_number']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (batch?['selling_price'] as num?)?.toDouble() ?? 0.0,
      manufactureDate: batch?['manufacture_date']?.toString() ?? '',
      expiryDate: batch?['expiry_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // For Laravel StorePurchaseInvoiceRequest
    return {
      'medicine_id': medicineId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'manufacture_date': manufactureDate,
      'expiry_date': expiryDate,
    };
  }
}
