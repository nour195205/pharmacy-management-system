import 'package:desktop/features/sales/domain/entities/sales_invoice_item.dart';

class SalesInvoice {
  final String id;
  final int branchId;
  final String? customerId;
  final String? customerName;
  final String date;
  final double total;
  final String status; // 'مدفوع', 'معلق', 'ملغى'
  final String paymentMethod; // 'نقدا', 'بطاقة', 'أخرى'
  final String? note;
  final int createdBy;
  final List<SalesInvoiceItem> items;
  final bool isSynced;
  final String? createdAt;

  const SalesInvoice({
    required this.id,
    required this.branchId,
    this.customerId,
    this.customerName,
    required this.date,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.note,
    required this.createdBy,
    required this.items,
    this.isSynced = false,
    this.createdAt,
  });
}
