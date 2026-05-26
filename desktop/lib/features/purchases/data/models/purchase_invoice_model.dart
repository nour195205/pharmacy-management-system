import 'package:desktop/features/purchases/data/models/purchase_invoice_item_model.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';

class PurchaseInvoiceModel extends PurchaseInvoice {
  const PurchaseInvoiceModel({
    required super.id,
    required super.branchId,
    required super.supplierId,
    super.supplierName,
    required super.userId,
    required super.invoiceDate,
    required super.totalAmount,
    required super.items,
    super.isSynced,
    super.createdAt,
  });

  factory PurchaseInvoiceModel.fromMap(Map<String, dynamic> map, {List<PurchaseInvoiceItemModel> items = const []}) {
    return PurchaseInvoiceModel(
      id: map['id']?.toString() ?? '',
      branchId: (map['branch_id'] as num?)?.toInt() ?? 1,
      supplierId: map['supplier_id']?.toString() ?? '',
      supplierName: map['supplier_name']?.toString(),
      userId: (map['user_id'] as num?)?.toInt() ?? 1,
      invoiceDate: map['invoice_date']?.toString() ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int?) == 1,
      createdAt: map['created_at']?.toString(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'supplier_id': supplierId,
      'user_id': userId,
      'invoice_date': invoiceDate,
      'total_amount': totalAmount,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory PurchaseInvoiceModel.fromJson(Map<String, dynamic> json) {
    // Parsing remote JSON from PurchaseInvoiceResource
    final supplier = json['supplier'] as Map<String, dynamic>?;
    
    List<PurchaseInvoiceItemModel> parsedItems = [];
    if (json['items'] != null) {
      final list = json['items'] as List;
      parsedItems = list.map((e) => PurchaseInvoiceItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return PurchaseInvoiceModel(
      id: json['id']?.toString() ?? '',
      branchId: (json['branch']?['id'] as num?)?.toInt() ?? 1,
      supplierId: supplier?['id']?.toString() ?? '',
      supplierName: supplier?['name']?.toString(),
      userId: 1, // User is not always strictly returned
      invoiceDate: json['invoice_date']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString(),
      isSynced: true,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    // For Laravel StorePurchaseInvoiceRequest
    return {
      'branch_id': branchId,
      'supplier_id': supplierId,
      'invoice_date': invoiceDate,
      'items': items.map((item) {
        return (item as PurchaseInvoiceItemModel).toJson();
      }).toList(),
    };
  }
}
