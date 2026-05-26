import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:desktop/services/database_service.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardData> getDashboardData();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final DatabaseService databaseService;

  DashboardLocalDataSourceImpl(this.databaseService);

  @override
  Future<DashboardData> getDashboardData() async {
    final db = await databaseService.database;

    // 1. Total medicines count (matches: Medicine::count())
    final medicinesResult = await db.rawQuery('SELECT COUNT(*) as count FROM medicines');
    final totalMedicines = (medicinesResult.first['count'] as int?) ?? 0;

    // 2. Total suppliers count (matches: Supplier::count())
    final suppliersResult = await db.rawQuery('SELECT COUNT(*) as count FROM suppliers');
    final totalSuppliers = (suppliersResult.first['count'] as int?) ?? 0;

    // 3. Net Sales Today (matches: SalesInvoice::whereDate('date', today)->sum('total'))
    final today = DateTime.now().toIso8601String().split('T').first;

    final grossSalesResult = await db.rawQuery(
      "SELECT COALESCE(SUM(total), 0) as total FROM sales_invoices WHERE date LIKE ?",
      ['$today%'],
    );
    final grossSalesToday = (grossSalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Note: sales_returns table may not exist in local DB yet, default to 0
    double salesReturnsToday = 0.0;
    try {
      final salesReturnsResult = await db.rawQuery(
        "SELECT COALESCE(SUM(total), 0) as total FROM sales_returns WHERE date LIKE ?",
        ['$today%'],
      );
      salesReturnsToday = (salesReturnsResult.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      // sales_returns table may not exist locally
    }
    final netSalesToday = grossSalesToday - salesReturnsToday;

    // 4. Net Purchases Today — purchase_invoices table may not exist locally
    double netPurchasesToday = 0.0;
    try {
      final grossPurchasesResult = await db.rawQuery(
        "SELECT COALESCE(SUM(total_amount), 0) as total FROM purchase_invoices WHERE invoice_date LIKE ?",
        ['$today%'],
      );
      final grossPurchasesToday = (grossPurchasesResult.first['total'] as num?)?.toDouble() ?? 0.0;

      double purchaseReturnsToday = 0.0;
      try {
        final purchaseReturnsResult = await db.rawQuery(
          "SELECT COALESCE(SUM(total), 0) as total FROM purchase_returns WHERE date LIKE ?",
          ['$today%'],
        );
        purchaseReturnsToday = (purchaseReturnsResult.first['total'] as num?)?.toDouble() ?? 0.0;
      } catch (_) {}

      netPurchasesToday = grossPurchasesToday - purchaseReturnsToday;
    } catch (_) {
      // purchase_invoices table may not exist locally
    }

    // 5. Low Stock Medicines (matches Laravel: SUM(batches.quantity) <= medicines.reorder_level AND > 0)
    List<LowStockItem> lowStockMedicines = [];
    try {
      final lowStockResult = await db.rawQuery('''
        SELECT medicines.name as medicine_name, SUM(batches.quantity) as total_quantity
        FROM batches
        INNER JOIN medicines ON batches.medicine_id = medicines.id
        GROUP BY medicines.id, medicines.name, medicines.reorder_level
        HAVING SUM(batches.quantity) <= CAST(medicines.reorder_level AS REAL) AND SUM(batches.quantity) > 0
      ''');
      lowStockMedicines = lowStockResult.map((row) {
        return LowStockItem(
          medicineName: row['medicine_name'] as String,
          totalQuantity: (row['total_quantity'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      // Handle case where tables are empty or schema mismatch
    }

    // 6. Expiring Soon Batches (matches Laravel: expiry_date between today and today+90, quantity > 0)
    List<ExpiringSoonItem> expiringSoonBatches = [];
    try {
      final soonDate = DateTime.now().add(const Duration(days: 90)).toIso8601String().split('T').first;
      final expiringSoonResult = await db.rawQuery('''
        SELECT medicines.name as medicine_name, batches.batch_number, batches.expiry_date, batches.quantity
        FROM batches
        INNER JOIN medicines ON batches.medicine_id = medicines.id
        WHERE batches.expiry_date >= ? AND batches.expiry_date <= ? AND batches.quantity > 0
        ORDER BY batches.expiry_date ASC
      ''', [today, soonDate]);

      expiringSoonBatches = expiringSoonResult.map((row) {
        return ExpiringSoonItem(
          medicineName: row['medicine_name'] as String,
          batchNumber: row['batch_number'] as String,
          expiryDate: row['expiry_date'] as String,
          quantity: (row['quantity'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      // Handle case where tables are empty or schema mismatch
    }

    return DashboardData(
      totalMedicines: totalMedicines,
      totalSuppliers: totalSuppliers,
      netSalesToday: netSalesToday,
      netPurchasesToday: netPurchasesToday,
      lowStockMedicines: lowStockMedicines,
      expiringSoonBatches: expiringSoonBatches,
    );
  }
}
