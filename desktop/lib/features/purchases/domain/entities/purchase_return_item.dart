class PurchaseReturnItem {
  final String? id;
  final String? purchaseReturnId;
  final String batchId;
  final String? batchNumber;
  final String? medicineName;
  final int quantity;
  final double purchasePrice;
  final double total;

  const PurchaseReturnItem({
    this.id,
    this.purchaseReturnId,
    required this.batchId,
    this.batchNumber,
    this.medicineName,
    required this.quantity,
    required this.purchasePrice,
    required this.total,
  });
}
