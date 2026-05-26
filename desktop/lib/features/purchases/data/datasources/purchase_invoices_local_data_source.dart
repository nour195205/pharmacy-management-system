import 'package:uuid/uuid.dart';
import 'package:desktop/features/purchases/data/models/purchase_invoice_item_model.dart';
import 'package:desktop/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class PurchaseInvoicesLocalDataSource {
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices();
  Future<PurchaseInvoiceModel> createPurchaseInvoice(PurchaseInvoiceModel invoice);
}

class PurchaseInvoicesLocalDataSourceImpl implements PurchaseInvoicesLocalDataSource {
  final DatabaseService databaseService;
  final _uuid = const Uuid();

  PurchaseInvoicesLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    final db = await databaseService.database;

    final List<Map<String, dynamic>> invoiceMaps = await db.rawQuery('''
      SELECT 
        pi.*,
        s.name as supplier_name
      FROM purchase_invoices pi
      LEFT JOIN suppliers s ON pi.supplier_id = s.id
      ORDER BY pi.created_at DESC
    ''');

    List<PurchaseInvoiceModel> invoices = [];

    for (var invoiceMap in invoiceMaps) {
      final invoiceId = invoiceMap['id'];

      // Fetch items and join with batches and medicines
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT 
          pii.*,
          b.batch_number, b.manufacture_date, b.expiry_date, b.selling_price, b.medicine_id,
          m.name as medicine_name
        FROM purchase_invoice_items pii
        LEFT JOIN batches b ON pii.batch_id = b.id
        LEFT JOIN medicines m ON b.medicine_id = m.id
        WHERE pii.purchase_invoice_id = ?
      ''', [invoiceId]);

      final items = itemMaps.map((itemMap) => PurchaseInvoiceItemModel.fromMap(itemMap)).toList();
      invoices.add(PurchaseInvoiceModel.fromMap(invoiceMap, items: items));
    }

    return invoices;
  }

  @override
  Future<PurchaseInvoiceModel> createPurchaseInvoice(PurchaseInvoiceModel invoice) async {
    final db = await databaseService.database;
    final invoiceId = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    // Calculate total amount
    double totalAmount = 0;
    for (var item in invoice.items) {
      totalAmount += item.quantity * item.purchasePrice;
    }

    // Wrap in transaction (offline-first writes to 3 tables: purchase_invoices, batches, purchase_invoice_items)
    await db.transaction((txn) async {
      // 1. Create Invoice
      await txn.insert('purchase_invoices', {
        'id': invoiceId,
        'branch_id': invoice.branchId,
        'supplier_id': invoice.supplierId,
        'user_id': invoice.userId,
        'invoice_date': invoice.invoiceDate,
        'total_amount': totalAmount,
        'is_synced': 0,
        'created_at': now,
        'updated_at': now,
      });

      // 2. Create Items & Batches
      for (var item in invoice.items) {
        final batchId = _uuid.v4();
        // Generate temporary batch number matching backend style roughly
        final tempBatchNumber = 'BATCH-\${item.medicineId}-\${DateTime.now().millisecondsSinceEpoch}';

        await txn.insert('batches', {
          'id': batchId,
          'medicine_id': item.medicineId,
          'batch_number': tempBatchNumber,
          'manufacture_date': item.manufactureDate,
          'expiry_date': item.expiryDate,
          'quantity': item.quantity,
          'purchase_price': item.purchasePrice,
          'selling_price': item.sellingPrice,
          'branch_id': invoice.branchId,
          'is_synced': 0,
          'created_at': now,
          'updated_at': now,
        });

        final itemId = _uuid.v4();
        await txn.insert('purchase_invoice_items', {
          'id': itemId,
          'purchase_invoice_id': invoiceId,
          'batch_id': batchId,
          'qty': item.quantity,
          'price': item.purchasePrice,
        });
      }
    });

    // Return the inserted invoice with updated ID
    return PurchaseInvoiceModel(
      id: invoiceId,
      branchId: invoice.branchId,
      supplierId: invoice.supplierId,
      supplierName: invoice.supplierName, // Passed through from UI
      userId: invoice.userId,
      invoiceDate: invoice.invoiceDate,
      totalAmount: totalAmount,
      items: invoice.items,
      isSynced: false,
      createdAt: now,
    );
  }
}
