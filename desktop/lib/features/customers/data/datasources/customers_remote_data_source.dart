import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/data/models/customer_model.dart';
import 'package:desktop/services/api_service.dart';

abstract class CustomersRemoteDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  final ApiService apiService;

  CustomersRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final Response response = await apiService.get('/customers');
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        final List list = responseData['data'];
        return list.map((item) => CustomerModel.fromJson(item)).toList();
      }
      return [];
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final Response response = await apiService.post('/customers', data: customer.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return CustomerModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final Response response = await apiService.put('/customers/${customer.id}', data: customer.toJson());
      final responseData = response.data;
      if (responseData != null && responseData['data'] != null) {
        return CustomerModel.fromJson(responseData['data']);
      }
      throw ServerException('Failed to parse server response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await apiService.delete('/customers/$id');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
