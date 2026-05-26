import 'package:desktop/features/sales/data/models/sales_invoice_item_model.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';

class SalesInvoiceModel extends SalesInvoice {
  const SalesInvoiceModel({
    required super.id,
    required super.branchId,
    super.customerId,
    super.customerName,
    required super.date,
    required super.total,
    required super.status,
    required super.paymentMethod,
    super.note,
    required super.createdBy,
    required super.items,
    super.isSynced,
    super.createdAt,
  });

  factory SalesInvoiceModel.fromMap(Map<String, dynamic> map, {List<SalesInvoiceItemModel> items = const []}) {
    return SalesInvoiceModel(
      id: map['id']?.toString() ?? '',
      branchId: (map['branch_id'] as num?)?.toInt() ?? 1,
      customerId: map['customer_id']?.toString(),
      customerName: map['customer_name']?.toString(),
      date: map['date']?.toString() ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'مدفوع',
      paymentMethod: map['payment_method']?.toString() ?? 'نقدا',
      note: map['note']?.toString(),
      createdBy: (map['created_by'] as num?)?.toInt() ?? 1,
      isSynced: (map['is_synced'] as int?) == 1,
      createdAt: map['created_at']?.toString(),
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'customer_id': customerId,
      'date': date,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'note': note,
      'created_by': createdBy,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    
    List<SalesInvoiceItemModel> parsedItems = [];
    if (json['items'] != null) {
      final list = json['items'] as List;
      parsedItems = list.map((e) => SalesInvoiceItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return SalesInvoiceModel(
      id: json['id']?.toString() ?? '',
      branchId: (json['branch']?['id'] as num?)?.toInt() ?? 1,
      customerId: customer?['id']?.toString(),
      customerName: customer?['name']?.toString(),
      date: json['date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'مدفوع',
      paymentMethod: json['payment_method']?.toString() ?? 'نقدا',
      note: json['note']?.toString(),
      createdBy: 1, // Defaulting for remote mapping
      createdAt: json['created_at']?.toString(),
      isSynced: true,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'customer_id': customerId,
      'date': date,
      'status': status,
      'payment_method': paymentMethod,
      'note': note,
      'items': items.map((item) {
        return (item as SalesInvoiceItemModel).toJson();
      }).toList(),
    };
  }
}
