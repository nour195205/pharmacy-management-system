import 'package:desktop/features/sales/data/models/sales_invoice_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class SalesInvoicesRemoteDataSource {
  Future<List<SalesInvoiceModel>> getSalesInvoices();
  Future<SalesInvoiceModel> createSalesInvoice(SalesInvoiceModel invoice);
}

class SalesInvoicesRemoteDataSourceImpl implements SalesInvoicesRemoteDataSource {
  final ApiService apiService;

  SalesInvoicesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<SalesInvoiceModel>> getSalesInvoices() async {
    final response = await apiService.get('/sales-invoices');
    final responseData = response.data;
    if (responseData != null && responseData['data'] != null) {
      final list = responseData['data'] as List;
      return list.map((e) => SalesInvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SalesInvoiceModel> createSalesInvoice(SalesInvoiceModel invoice) async {
    final response = await apiService.post('/sales-invoices', data: invoice.toJson());
    final responseData = response.data;
    if (responseData != null && responseData['data'] != null) {
      return SalesInvoiceModel.fromJson(responseData['data'] as Map<String, dynamic>);
    }
    throw Exception('فشل في إنشاء فاتورة مبيعات على الخادم البعيد');
  }
}
