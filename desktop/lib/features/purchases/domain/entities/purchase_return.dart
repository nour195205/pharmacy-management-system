import 'package:desktop/features/purchases/domain/entities/purchase_return_item.dart';

class PurchaseReturn {
  final String id;
  final String purchaseInvoiceId;
  final String? supplierName;
  final int userId;
  final String date;
  final double total;
  final String? reason;
  final int createdBy;
  final List<PurchaseReturnItem> items;
  final bool isSynced;
  final String? createdAt;

  const PurchaseReturn({
    required this.id,
    required this.purchaseInvoiceId,
    this.supplierName,
    required this.userId,
    required this.date,
    required this.total,
    this.reason,
    required this.createdBy,
    required this.items,
    this.isSynced = false,
    this.createdAt,
  });
}
