class SalesInvoiceItem {
  final String id;
  final String salesInvoiceId;
  final String batchId;
  final String? batchNumber;
  final String? medicineName;
  final int quantity;
  final int price;

  const SalesInvoiceItem({
    required this.id,
    required this.salesInvoiceId,
    required this.batchId,
    this.batchNumber,
    this.medicineName,
    required this.quantity,
    required this.price,
  });

  double get total => (quantity * price).toDouble();
}
