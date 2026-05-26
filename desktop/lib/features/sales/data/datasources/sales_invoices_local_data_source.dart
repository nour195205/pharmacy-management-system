import 'package:uuid/uuid.dart';
import 'package:desktop/features/sales/data/models/sales_invoice_item_model.dart';
import 'package:desktop/features/sales/data/models/sales_invoice_model.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice_item.dart';
import 'package:desktop/services/database_service.dart';

abstract class SalesInvoicesLocalDataSource {
  Future<List<SalesInvoiceModel>> getSalesInvoices();
  Future<SalesInvoiceModel> createSalesInvoice(SalesInvoiceModel invoice);
  Future<SalesInvoiceModel> updateSalesInvoice(SalesInvoiceModel invoice);
  Future<void> deleteSalesInvoice(String id);
}

class SalesInvoicesLocalDataSourceImpl implements SalesInvoicesLocalDataSource {
  final DatabaseService databaseService;
  final _uuid = const Uuid();

  SalesInvoicesLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<SalesInvoiceModel>> getSalesInvoices() async {
    final db = await databaseService.database;

    final List<Map<String, dynamic>> invoiceMaps = await db.rawQuery('''
      SELECT 
        si.*,
        c.name as customer_name
      FROM sales_invoices si
      LEFT JOIN customers c ON si.customer_id = c.id
      ORDER BY si.created_at DESC
    ''');

    List<SalesInvoiceModel> invoices = [];

    for (var invoiceMap in invoiceMaps) {
      final invoiceId = invoiceMap['id'];

      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT 
          sii.*,
          b.batch_number, b.selling_price, b.medicine_id,
          m.name as medicine_name
        FROM sales_invoice_items sii
        LEFT JOIN batches b ON sii.batch_id = b.id
        LEFT JOIN medicines m ON b.medicine_id = m.id
        WHERE sii.sales_invoice_id = ?
      ''', [invoiceId]);

      final items = itemMaps.map((itemMap) => SalesInvoiceItemModel.fromMap(itemMap)).toList();
      invoices.add(SalesInvoiceModel.fromMap(invoiceMap, items: items));
    }

    return invoices;
  }

  @override
  Future<SalesInvoiceModel> createSalesInvoice(SalesInvoiceModel invoice) async {
    final db = await databaseService.database;
    final invoiceId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Insert Invoice
      await txn.insert('sales_invoices', {
        'id': invoiceId,
        'branch_id': invoice.branchId,
        'customer_id': invoice.customerId,
        'date': invoice.date,
        'total': invoice.total,
        'status': invoice.status,
        'payment_method': invoice.paymentMethod,
        'note': invoice.note,
        'created_by': invoice.createdBy,
        'is_synced': 0,
        'created_at': now,
        'updated_at': now,
      });

      // 2. Insert Items & Decrement Stock
      for (var item in invoice.items) {
        final itemId = _uuid.v4();
        await txn.insert('sales_invoice_items', {
          'id': itemId,
          'sales_invoice_id': invoiceId,
          'batch_id': item.batchId,
          'qty': item.quantity,
          'price': item.price,
        });

        // Decrement batch stock
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }
    });

    return SalesInvoiceModel(
      id: invoiceId,
      branchId: invoice.branchId,
      customerId: invoice.customerId,
      customerName: invoice.customerName,
      date: invoice.date,
      total: invoice.total,
      status: invoice.status,
      paymentMethod: invoice.paymentMethod,
      note: invoice.note,
      createdBy: invoice.createdBy,
      items: invoice.items.map((item) => SalesInvoiceItem(
        id: _uuid.v4(),
        salesInvoiceId: invoiceId,
        batchId: item.batchId,
        batchNumber: item.batchNumber,
        medicineName: item.medicineName,
        quantity: item.quantity,
        price: item.price,
      )).toList(),
      isSynced: false,
      createdAt: now,
    );
  }

  @override
  Future<SalesInvoiceModel> updateSalesInvoice(SalesInvoiceModel invoice) async {
    final db = await databaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Fetch old items in this invoice to replenish stock first
      final List<Map<String, dynamic>> oldItemMaps = await txn.query(
        'sales_invoice_items',
        where: 'sales_invoice_id = ?',
        whereArgs: [invoice.id],
      );

      // 2. Replenish stock by incrementing quantities back
      for (var itemMap in oldItemMaps) {
        final batchId = itemMap['batch_id'] as String;
        final qty = itemMap['qty'] as int;
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity + ? WHERE id = ?',
          [qty, batchId],
        );
      }

      // 3. Delete old items
      await txn.delete(
        'sales_invoice_items',
        where: 'sales_invoice_id = ?',
        whereArgs: [invoice.id],
      );

      // 4. Insert new items and decrement stock accordingly
      for (var item in invoice.items) {
        final itemId = _uuid.v4();
        await txn.insert('sales_invoice_items', {
          'id': itemId,
          'sales_invoice_id': invoice.id,
          'batch_id': item.batchId,
          'qty': item.quantity,
          'price': item.price,
        });

        // Decrement batch stock
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }

      // 5. Update invoice
      await txn.update(
        'sales_invoices',
        {
          'branch_id': invoice.branchId,
          'customer_id': invoice.customerId,
          'date': invoice.date,
          'total': invoice.total,
          'status': invoice.status,
          'payment_method': invoice.paymentMethod,
          'note': invoice.note,
          'is_synced': 0,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [invoice.id],
      );
    });

    return SalesInvoiceModel(
      id: invoice.id,
      branchId: invoice.branchId,
      customerId: invoice.customerId,
      customerName: invoice.customerName,
      date: invoice.date,
      total: invoice.total,
      status: invoice.status,
      paymentMethod: invoice.paymentMethod,
      note: invoice.note,
      createdBy: invoice.createdBy,
      items: invoice.items,
      isSynced: false,
      createdAt: invoice.createdAt ?? now,
    );
  }

  @override
  Future<void> deleteSalesInvoice(String id) async {
    final db = await databaseService.database;

    await db.transaction((txn) async {
      // 1. Fetch items to replenish stock
      final List<Map<String, dynamic>> itemMaps = await txn.query(
        'sales_invoice_items',
        where: 'sales_invoice_id = ?',
        whereArgs: [id],
      );

      // 2. Replenish stock by incrementing quantities back
      for (var itemMap in itemMaps) {
        final batchId = itemMap['batch_id'] as String;
        final qty = itemMap['qty'] as int;
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity + ? WHERE id = ?',
          [qty, batchId],
        );
      }

      // 3. Delete invoice (cascade delete handles items, but we delete explicitly as well to be fully clean)
      await txn.delete(
        'sales_invoice_items',
        where: 'sales_invoice_id = ?',
        whereArgs: [id],
      );

      await txn.delete(
        'sales_invoices',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
