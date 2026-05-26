import 'package:uuid/uuid.dart';
import 'package:desktop/features/sales/data/models/sales_return_item_model.dart';
import 'package:desktop/features/sales/data/models/sales_return_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class SalesReturnsLocalDataSource {
  Future<List<SalesReturnModel>> getSalesReturns();
  Future<SalesReturnModel> createSalesReturn(SalesReturnModel salesReturn);
}

class SalesReturnsLocalDataSourceImpl implements SalesReturnsLocalDataSource {
  final DatabaseService databaseService;
  final _uuid = const Uuid();

  SalesReturnsLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<SalesReturnModel>> getSalesReturns() async {
    final db = await databaseService.database;

    final List<Map<String, dynamic>> returnMaps = await db.rawQuery('''
      SELECT 
        sr.*,
        c.name as customer_name
      FROM sales_returns sr
      LEFT JOIN sales_invoices si ON sr.sales_invoice_id = si.id
      LEFT JOIN customers c ON si.customer_id = c.id
      ORDER BY sr.created_at DESC
    ''');

    List<SalesReturnModel> returns = [];

    for (var returnMap in returnMaps) {
      final returnId = returnMap['id'];

      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT 
          sri.*,
          b.batch_number,
          m.name as medicine_name
        FROM sales_return_items sri
        LEFT JOIN batches b ON sri.batch_id = b.id
        LEFT JOIN medicines m ON b.medicine_id = m.id
        WHERE sri.sales_return_id = ?
      ''', [returnId]);

      final items = itemMaps.map((itemMap) => SalesReturnItemModel.fromMap(itemMap)).toList();
      returns.add(SalesReturnModel.fromMap(returnMap, items: items));
    }

    return returns;
  }

  @override
  Future<SalesReturnModel> createSalesReturn(SalesReturnModel salesReturn) async {
    final db = await databaseService.database;
    final returnId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // 1. Insert Return
      await txn.insert('sales_returns', {
        'id': returnId,
        'sales_invoice_id': salesReturn.salesInvoiceId,
        'date': salesReturn.date,
        'total': salesReturn.total,
        'reason': salesReturn.reason,
        'created_by': salesReturn.createdBy,
        'is_synced': 0,
        'created_at': now,
        'updated_at': now,
      });

      // 2. Insert Items & Increment Stock
      for (var item in salesReturn.items) {
        final itemId = _uuid.v4();
        await txn.insert('sales_return_items', {
          'id': itemId,
          'sales_return_id': returnId,
          'batch_id': item.batchId,
          'quantity': item.quantity,
          'selling_price': item.sellingPrice,
          'total': item.total,
        });

        // Restore stock in batch
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity + ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }
    });

    return SalesReturnModel(
      id: returnId,
      salesInvoiceId: salesReturn.salesInvoiceId,
      date: salesReturn.date,
      total: salesReturn.total,
      reason: salesReturn.reason,
      createdBy: salesReturn.createdBy,
      items: salesReturn.items,
      isSynced: false,
      createdAt: now,
      customerName: salesReturn.customerName,
    );
  }
}
