import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/data/models/purchase_return_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class PurchaseReturnsRemoteDataSource {
  Future<List<PurchaseReturnModel>> getPurchaseReturns();
}

class PurchaseReturnsRemoteDataSourceImpl implements PurchaseReturnsRemoteDataSource {
  final ApiService apiService;

  PurchaseReturnsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<PurchaseReturnModel>> getPurchaseReturns() async {
    try {
      final Response response = await apiService.get('/purchase-returns');
      final responseData = response.data;

      if (responseData != null && responseData['data'] != null) {
        final List data = responseData['data'];
        return data.map((json) => PurchaseReturnModel.fromJson(json)).toList();
      }
      return [];
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
