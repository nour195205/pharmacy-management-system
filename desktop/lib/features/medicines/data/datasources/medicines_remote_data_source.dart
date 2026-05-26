import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/medicines/data/models/medicine_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class MedicinesRemoteDataSource {
  Future<List<MedicineModel>> getMedicines();
  Future<MedicineModel> createMedicine(MedicineModel medicine);
  Future<MedicineModel> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
}

class MedicinesRemoteDataSourceImpl implements MedicinesRemoteDataSource {
  final ApiService apiService;

  MedicinesRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<MedicineModel>> getMedicines() async {
    try {
      final Response response = await apiService.get('/medicines');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final List list = responseData['data'];
        return list.map((item) => MedicineModel.fromJson(item)).toList();
      }
      return [];
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MedicineModel> createMedicine(MedicineModel medicine) async {
    try {
      final Response response = await apiService.post('/medicines', data: medicine.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return MedicineModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    try {
      final Response response = await apiService.put('/medicines/${medicine.id}', data: medicine.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return MedicineModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMedicine(String id) async {
    try {
      await apiService.delete('/medicines/$id');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
