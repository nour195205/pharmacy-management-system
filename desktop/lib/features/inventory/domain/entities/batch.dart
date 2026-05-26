class Batch {
  final String id;
  final String medicineId;
  final String? medicineName; // Resolved from JOIN
  final String batchNumber;
  final String manufactureDate;
  final String expiryDate;
  final double quantity;
  final int purchasePrice;
  final int sellingPrice;
  final int branchId;
  final bool isSynced;

  const Batch({
    required this.id,
    required this.medicineId,
    this.medicineName,
    required this.batchNumber,
    required this.manufactureDate,
    required this.expiryDate,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.branchId,
    this.isSynced = false,
  });

  Batch copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? batchNumber,
    String? manufactureDate,
    String? expiryDate,
    double? quantity,
    int? purchasePrice,
    int? sellingPrice,
    int? branchId,
    bool? isSynced,
  }) {
    return Batch(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      batchNumber: batchNumber ?? this.batchNumber,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      branchId: branchId ?? this.branchId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
