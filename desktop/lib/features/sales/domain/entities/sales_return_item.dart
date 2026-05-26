class SalesReturnItem {
  final String id;
  final String salesReturnId;
  final String batchId;
  final String? batchNumber;
  final String? medicineName;
  final int quantity;
  final double sellingPrice;
  final double total;

  const SalesReturnItem({
    required this.id,
    required this.salesReturnId,
    required this.batchId,
    this.batchNumber,
    this.medicineName,
    required this.quantity,
    required this.sellingPrice,
    required this.total,
  });
}
