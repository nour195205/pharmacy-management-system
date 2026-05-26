import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:desktop/services/api_service.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardData> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiService apiService;

  DashboardRemoteDataSourceImpl(this.apiService);

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final Response response = await apiService.get('/dashboard');
      final responseData = response.data;

      if (responseData != null && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;

        // Parse low stock medicines
        List<LowStockItem> lowStockMedicines = [];
        if (data['lowStockMedicines'] != null) {
          final list = data['lowStockMedicines'] as List;
          lowStockMedicines = list.map((item) {
            return LowStockItem(
              medicineName: (item['medicine_name'] ?? '') as String,
              totalQuantity: (item['total_quantity'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();
        }

        // Parse expiring soon batches
        List<ExpiringSoonItem> expiringSoonBatches = [];
        if (data['expiringSoonBatches'] != null) {
          final list = data['expiringSoonBatches'] as List;
          expiringSoonBatches = list.map((item) {
            final medicine = item['medicine'] as Map<String, dynamic>?;
            return ExpiringSoonItem(
              medicineName: medicine?['name'] ?? '',
              batchNumber: (item['batch_number'] ?? '') as String,
              expiryDate: (item['expiry_date'] ?? '') as String,
              quantity: (item['quantity'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();
        }

        return DashboardData(
          totalMedicines: (data['totalMedicines'] as num?)?.toInt() ?? 0,
          totalSuppliers: (data['totalSuppliers'] as num?)?.toInt() ?? 0,
          netSalesToday: (data['netSalesToday'] as num?)?.toDouble() ?? 0.0,
          netPurchasesToday: (data['netPurchasesToday'] as num?)?.toDouble() ?? 0.0,
          lowStockMedicines: lowStockMedicines,
          expiringSoonBatches: expiringSoonBatches,
        );
      }

      throw ServerException('Failed to parse dashboard response');
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
