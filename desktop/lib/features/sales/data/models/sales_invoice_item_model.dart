import 'package:desktop/features/sales/domain/entities/sales_invoice_item.dart';

class SalesInvoiceItemModel extends SalesInvoiceItem {
  const SalesInvoiceItemModel({
    required super.id,
    required super.salesInvoiceId,
    required super.batchId,
    super.batchNumber,
    super.medicineName,
    required super.quantity,
    required super.price,
  });

  factory SalesInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return SalesInvoiceItemModel(
      id: map['id']?.toString() ?? '',
      salesInvoiceId: map['sales_invoice_id']?.toString() ?? '',
      batchId: map['batch_id']?.toString() ?? '',
      batchNumber: map['batch_number']?.toString(),
      medicineName: map['medicine_name']?.toString(),
      quantity: (map['qty'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sales_invoice_id': salesInvoiceId,
      'batch_id': batchId,
      'qty': quantity,
      'price': price,
    };
  }

  factory SalesInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'] as Map<String, dynamic>?;
    final medicine = batch?['medicine'] as Map<String, dynamic>?;

    return SalesInvoiceItemModel(
      id: json['id']?.toString() ?? '',
      salesInvoiceId: json['sales_invoice_id']?.toString() ?? '',
      batchId: batch?['id']?.toString() ?? '',
      batchNumber: batch?['batch_number']?.toString(),
      medicineName: medicine?['name']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'quantity': quantity,
    };
  }
}
