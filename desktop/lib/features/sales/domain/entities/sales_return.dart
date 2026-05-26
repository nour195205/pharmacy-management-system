import 'package:desktop/features/sales/domain/entities/sales_return_item.dart';

class SalesReturn {
  final String id;
  final String salesInvoiceId;
  final String date;
  final double total;
  final String? reason;
  final int createdBy;
  final List<SalesReturnItem> items;
  final bool isSynced;
  final String? createdAt;
  final String? customerName;

  const SalesReturn({
    required this.id,
    required this.salesInvoiceId,
    required this.date,
    required this.total,
    this.reason,
    required this.createdBy,
    required this.items,
    this.isSynced = false,
    this.createdAt,
    this.customerName,
  });
}
