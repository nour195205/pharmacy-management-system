/// Dashboard statistics entity matching Laravel DashboardService output
class DashboardData {
  final int totalMedicines;
  final int totalSuppliers;
  final double netSalesToday;
  final double netPurchasesToday;
  final List<LowStockItem> lowStockMedicines;
  final List<ExpiringSoonItem> expiringSoonBatches;

  const DashboardData({
    required this.totalMedicines,
    required this.totalSuppliers,
    required this.netSalesToday,
    required this.netPurchasesToday,
    required this.lowStockMedicines,
    required this.expiringSoonBatches,
  });
}

/// Low stock medicine alert item
class LowStockItem {
  final String medicineName;
  final double totalQuantity;

  const LowStockItem({
    required this.medicineName,
    required this.totalQuantity,
  });
}

/// Batch expiring soon alert item
class ExpiringSoonItem {
  final String medicineName;
  final String batchNumber;
  final String expiryDate;
  final double quantity;

  const ExpiringSoonItem({
    required this.medicineName,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
  });
}
