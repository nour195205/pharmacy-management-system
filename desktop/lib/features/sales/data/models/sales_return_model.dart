import 'package:desktop/features/sales/data/models/sales_return_item_model.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';

class SalesReturnModel extends SalesReturn {
  const SalesReturnModel({
    required super.id,
    required super.salesInvoiceId,
    required super.date,
    required super.total,
    super.reason,
    required super.createdBy,
    required super.items,
    super.isSynced,
    super.createdAt,
    super.customerName,
  });

  factory SalesReturnModel.fromMap(Map<String, dynamic> map, {List<SalesReturnItemModel> items = const []}) {
    return SalesReturnModel(
      id: map['id']?.toString() ?? '',
      salesInvoiceId: map['sales_invoice_id']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason']?.toString(),
      createdBy: (map['created_by'] as num?)?.toInt() ?? 1,
      isSynced: (map['is_synced'] as int?) == 1,
      createdAt: map['created_at']?.toString(),
      customerName: map['customer_name']?.toString(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sales_invoice_id': salesInvoiceId,
      'date': date,
      'total': total,
      'reason': reason,
      'created_by': createdBy,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory SalesReturnModel.fromJson(Map<String, dynamic> json) {
    final invoice = json['sales_invoice'] as Map<String, dynamic>?;
    final customerName = invoice?['customer']?['name']?.toString();

    List<SalesReturnItemModel> parsedItems = [];
    if (json['items'] != null) {
      final list = json['items'] as List;
      parsedItems = list.map((e) => SalesReturnItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SalesReturnModel(
      id: json['id']?.toString() ?? '',
      salesInvoiceId: invoice?['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString(),
      createdBy: (json['user']?['id'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at']?.toString(),
      customerName: customerName,
      isSynced: true,
      items: parsedItems,
    );
  }
}
