class PurchaseInvoiceItem {
  final String? id;
  final String? purchaseInvoiceId;
  final String medicineId;
  final String? medicineName;
  final String? batchId;
  final String? batchNumber;
  final int quantity;
  final double purchasePrice;
  final double sellingPrice;
  final String manufactureDate;
  final String expiryDate;

  const PurchaseInvoiceItem({
    this.id,
    this.purchaseInvoiceId,
    required this.medicineId,
    this.medicineName,
    this.batchId,
    this.batchNumber,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.manufactureDate,
    required this.expiryDate,
  });
}
