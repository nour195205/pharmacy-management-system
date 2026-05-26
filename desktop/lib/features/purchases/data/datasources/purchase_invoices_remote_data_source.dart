import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class PurchaseInvoicesRemoteDataSource {
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices();
}

class PurchaseInvoicesRemoteDataSourceImpl implements PurchaseInvoicesRemoteDataSource {
  final ApiService apiService;

  PurchaseInvoicesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices() async {
    try {
      final Response response = await apiService.get('/purchase-invoices');
      final responseData = response.data;

      if (responseData != null && responseData['data'] != null) {
        final List data = responseData['data'];
        return data.map((json) => PurchaseInvoiceModel.fromJson(json)).toList();
      }
      return [];
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
