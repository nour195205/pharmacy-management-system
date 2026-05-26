import 'package:desktop/features/purchases/domain/entities/purchase_invoice_item.dart';

class PurchaseInvoice {
  final String id;
  final int branchId;
  final String supplierId;
  final String? supplierName;
  final int userId;
  final String invoiceDate;
  final double totalAmount;
  final List<PurchaseInvoiceItem> items;
  final bool isSynced;
  final String? createdAt;

  const PurchaseInvoice({
    required this.id,
    required this.branchId,
    required this.supplierId,
    this.supplierName,
    required this.userId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.items,
    this.isSynced = false,
    this.createdAt,
  });
}
