import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/sales/data/datasources/sales_returns_local_data_source.dart';
import 'package:desktop/features/sales/data/datasources/sales_returns_remote_data_source.dart';
import 'package:desktop/features/sales/data/models/sales_return_model.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';
import 'package:desktop/features/sales/domain/repositories/sales_returns_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class SalesReturnsRepositoryImpl implements SalesReturnsRepository {
  final SalesReturnsLocalDataSource localDataSource;
  final SalesReturnsRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  SalesReturnsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<SalesReturn>>> getSalesReturns() async {
    try {
      final localReturns = await localDataSource.getSalesReturns();
      return Right(localReturns);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب فواتير المرتجع محلياً: $e'));
    }
  }

  @override
  Future<Either<Failure, SalesReturn>> createSalesReturn(SalesReturn salesReturn) async {
    try {
      final returnModel = SalesReturnModel(
        id: salesReturn.id,
        salesInvoiceId: salesReturn.salesInvoiceId,
        date: salesReturn.date,
        total: salesReturn.total,
        reason: salesReturn.reason,
        createdBy: salesReturn.createdBy,
        items: salesReturn.items,
        customerName: salesReturn.customerName,
      );

      final createdReturn = await localDataSource.createSalesReturn(returnModel);

      // Prepare payload for background sync queue by resolving SQLite IDs to sales_item_id
      final db = await databaseService.database;
      List<Map<String, dynamic>> serializedItems = [];

      for (var item in createdReturn.items) {
        final List<Map<String, dynamic>> res = await db.query(
          'sales_invoice_items',
          columns: ['id'],
          where: 'sales_invoice_id = ? AND batch_id = ?',
          whereArgs: [createdReturn.salesInvoiceId, item.batchId],
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
        'sales_invoice_id': createdReturn.salesInvoiceId,
        'date': createdReturn.date,
        'reason': createdReturn.reason,
        'items': serializedItems,
      };

      // Queue operation in sqlite
      await databaseService.queueOperation(
        tableName: 'sales_returns',
        operationType: 'CREATE',
        recordId: createdReturn.id,
        payload: payload,
      );

      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return Right(createdReturn);
    } catch (e) {
      return Left(CacheFailure('فشل في إجراء عملية مرتجع مبيعات: $e'));
    }
  }
}
