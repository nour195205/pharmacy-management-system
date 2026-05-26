import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/inventory/data/models/batch_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class BatchesRemoteDataSource {
  Future<List<BatchModel>> getBatches();
  Future<BatchModel> createBatch(BatchModel batch);
  Future<BatchModel> updateBatch(BatchModel batch);
  Future<void> deleteBatch(String id);
}

class BatchesRemoteDataSourceImpl implements BatchesRemoteDataSource {
  final ApiService apiService;

  BatchesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<BatchModel>> getBatches() async {
    try {
      final Response response = await apiService.get('/batches');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final List list = responseData['data'];
        return list.map((item) => BatchModel.fromJson(item)).toList();
      }
      return [];
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BatchModel> createBatch(BatchModel batch) async {
    try {
      final Response response = await apiService.post('/batches', data: batch.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return BatchModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BatchModel> updateBatch(BatchModel batch) async {
    try {
      final Response response = await apiService.put('/batches/${batch.id}', data: batch.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return BatchModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBatch(String id) async {
    try {
      await apiService.delete('/batches/$id');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
