import 'package:uuid/uuid.dart';
import 'package:desktop/features/purchases/data/models/purchase_return_item_model.dart';
import 'package:desktop/features/purchases/data/models/purchase_return_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class PurchaseReturnsLocalDataSource {
  Future<List<PurchaseReturnModel>> getPurchaseReturns();
  Future<PurchaseReturnModel> createPurchaseReturn(PurchaseReturnModel purchaseReturn);
}

class PurchaseReturnsLocalDataSourceImpl implements PurchaseReturnsLocalDataSource {
  final DatabaseService databaseService;
  final _uuid = const Uuid();

  PurchaseReturnsLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<PurchaseReturnModel>> getPurchaseReturns() async {
    final db = await databaseService.database;

    final List<Map<String, dynamic>> returnMaps = await db.rawQuery('''
      SELECT 
        pr.*,
        s.name as supplier_name
      FROM purchase_returns pr
      LEFT JOIN purchase_invoices pi ON pr.purchase_invoice_id = pi.id
      LEFT JOIN suppliers s ON pi.supplier_id = s.id
      ORDER BY pr.created_at DESC
    ''');

    List<PurchaseReturnModel> returns = [];

    for (var returnMap in returnMaps) {
      final returnId = returnMap['id'];

      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT 
          pri.*,
          b.batch_number,
          m.name as medicine_name
        FROM purchase_return_items pri
        LEFT JOIN batches b ON pri.batch_id = b.id
        LEFT JOIN medicines m ON b.medicine_id = m.id
        WHERE pri.purchase_return_id = ?
      ''', [returnId]);

      final items = itemMaps.map((itemMap) => PurchaseReturnItemModel.fromMap(itemMap)).toList();
      returns.add(PurchaseReturnModel.fromMap(returnMap, items: items));
    }

    return returns;
  }

  @override
  Future<PurchaseReturnModel> createPurchaseReturn(PurchaseReturnModel purchaseReturn) async {
    final db = await databaseService.database;
    final returnId = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    // Offline-first: Transaction to save return, return items, and decrement batch quantity
    await db.transaction((txn) async {
      await txn.insert('purchase_returns', {
        'id': returnId,
        'purchase_invoice_id': purchaseReturn.purchaseInvoiceId,
        'user_id': purchaseReturn.userId,
        'date': purchaseReturn.date,
        'total': purchaseReturn.total,
        'reason': purchaseReturn.reason,
        'created_by': purchaseReturn.createdBy,
        'is_synced': 0,
        'created_at': now,
        'updated_at': now,
      });

      for (var item in purchaseReturn.items) {
        if (item.quantity <= 0) continue;

        final itemId = _uuid.v4();
        await txn.insert('purchase_return_items', {
          'id': itemId,
          'purchase_return_id': returnId,
          'batch_id': item.batchId,
          'quantity': item.quantity,
          'purchase_price': item.purchasePrice,
          'total': item.total,
        });

        // Decrement local batch quantity
        await txn.rawUpdate(
          'UPDATE batches SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }
    });

    return PurchaseReturnModel(
      id: returnId,
      purchaseInvoiceId: purchaseReturn.purchaseInvoiceId,
      supplierName: purchaseReturn.supplierName,
      userId: purchaseReturn.userId,
      date: purchaseReturn.date,
      total: purchaseReturn.total,
      reason: purchaseReturn.reason,
      createdBy: purchaseReturn.createdBy,
      items: purchaseReturn.items,
      isSynced: false,
      createdAt: now,
    );
  }
}
