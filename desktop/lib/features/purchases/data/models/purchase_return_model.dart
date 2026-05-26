import 'package:desktop/features/purchases/data/models/purchase_return_item_model.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';

class PurchaseReturnModel extends PurchaseReturn {
  const PurchaseReturnModel({
    required super.id,
    required super.purchaseInvoiceId,
    super.supplierName,
    required super.userId,
    required super.date,
    required super.total,
    super.reason,
    required super.createdBy,
    required super.items,
    super.isSynced,
    super.createdAt,
  });

  factory PurchaseReturnModel.fromMap(Map<String, dynamic> map, {List<PurchaseReturnItemModel> items = const []}) {
    return PurchaseReturnModel(
      id: map['id']?.toString() ?? '',
      purchaseInvoiceId: map['purchase_invoice_id']?.toString() ?? '',
      supplierName: map['supplier_name']?.toString(),
      userId: (map['user_id'] as num?)?.toInt() ?? 1,
      date: map['date']?.toString() ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason']?.toString(),
      createdBy: (map['created_by'] as num?)?.toInt() ?? 1,
      isSynced: (map['is_synced'] as int?) == 1,
      createdAt: map['created_at']?.toString(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_invoice_id': purchaseInvoiceId,
      'user_id': userId,
      'date': date,
      'total': total,
      'reason': reason,
      'created_by': createdBy,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    final invoice = json['purchase_invoice'] as Map<String, dynamic>?;
    final supplier = invoice?['supplier'] as Map<String, dynamic>?;

    List<PurchaseReturnItemModel> parsedItems = [];
    if (json['items'] != null) {
      final list = json['items'] as List;
      parsedItems = list.map((e) => PurchaseReturnItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return PurchaseReturnModel(
      id: json['id']?.toString() ?? '',
      purchaseInvoiceId: invoice?['id']?.toString() ?? '',
      supplierName: supplier?['name']?.toString(),
      userId: (json['user']?['id'] as num?)?.toInt() ?? 1,
      date: json['date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString(),
      createdBy: 1,
      createdAt: json['created_at']?.toString(),
      isSynced: true,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_invoice_id': purchaseInvoiceId,
      'date': date,
      'reason': reason,
      'items': items.map((item) {
        return (item as PurchaseReturnItemModel).toJson();
      }).toList(),
    };
  }
}
