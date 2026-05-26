import 'package:desktop/features/sales/data/models/sales_return_model.dart';
import 'package:desktop/services/api_service.dart';
import 'package:desktop/services/database_service.dart';

abstract class SalesReturnsRemoteDataSource {
  Future<List<SalesReturnModel>> getSalesReturns();
  Future<SalesReturnModel> createSalesReturn(SalesReturnModel salesReturn);
}

class SalesReturnsRemoteDataSourceImpl implements SalesReturnsRemoteDataSource {
  final ApiService apiService;
  final DatabaseService databaseService;

  SalesReturnsRemoteDataSourceImpl(this.apiService, this.databaseService);

  @override
  Future<List<SalesReturnModel>> getSalesReturns() async {
    final response = await apiService.get('/sales-returns');
    final responseData = response.data;
    if (responseData != null && responseData['data'] != null) {
      final list = responseData['data'] as List;
      return list.map((e) => SalesReturnModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SalesReturnModel> createSalesReturn(SalesReturnModel salesReturn) async {
    final db = await databaseService.database;
    List<Map<String, dynamic>> serializedItems = [];

    for (var item in salesReturn.items) {
      final List<Map<String, dynamic>> res = await db.query(
        'sales_invoice_items',
        columns: ['id'],
        where: 'sales_invoice_id = ? AND batch_id = ?',
        whereArgs: [salesReturn.salesInvoiceId, item.batchId],
      );

      if (res.isNotEmpty) {
        final salesItemId = res.first['id'].toString();
        serializedItems.add({
          'sales_item_id': salesItemId,
          'quantity': item.quantity,
        });
      }
    }

    final payload = {
      'sales_invoice_id': salesReturn.salesInvoiceId,
      'date': salesReturn.date,
      'reason': salesReturn.reason,
      'items': serializedItems,
    };

    final response = await apiService.post('/sales-returns', data: payload);
    final responseData = response.data;
    if (responseData != null && responseData['data'] != null) {
      return SalesReturnModel.fromJson(responseData['data'] as Map<String, dynamic>);
    }
    throw Exception('فشل في إرسال فاتورة مرتجع المبيعات إلى السيرفر');
  }
}
