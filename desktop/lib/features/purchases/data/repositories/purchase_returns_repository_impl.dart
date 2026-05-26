import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_returns_local_data_source.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_returns_remote_data_source.dart';
import 'package:desktop/features/purchases/data/models/purchase_return_model.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_returns_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class PurchaseReturnsRepositoryImpl implements PurchaseReturnsRepository {
  final PurchaseReturnsLocalDataSource localDataSource;
  final PurchaseReturnsRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  PurchaseReturnsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<PurchaseReturn>>> getPurchaseReturns() async {
    try {
      final localReturns = await localDataSource.getPurchaseReturns();
      return Right(localReturns);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب مرتجعات المشتريات من القاعدة المحلية: \$e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseReturn>> createPurchaseReturn(PurchaseReturn purchaseReturn) async {
    try {
      final returnModel = PurchaseReturnModel(
        id: purchaseReturn.id,
        purchaseInvoiceId: purchaseReturn.purchaseInvoiceId,
        supplierName: purchaseReturn.supplierName,
        userId: purchaseReturn.userId,
        date: purchaseReturn.date,
        total: purchaseReturn.total,
        reason: purchaseReturn.reason,
        createdBy: purchaseReturn.createdBy,
        items: purchaseReturn.items,
      );

      // 1. Create locally (saves return, subtracts batch quantites)
      final createdReturn = await localDataSource.createPurchaseReturn(returnModel);

      // 2. Queue for remote sync
      await databaseService.queueOperation(
        tableName: 'purchase_returns',
        operationType: 'CREATE',
        recordId: createdReturn.id,
        payload: createdReturn.toJson(), // Send payload matching Laravel StorePurchaseReturnRequest
      );

      // 3. Try to sync immediately if online
      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return Right(createdReturn);
    } catch (e) {
      return Left(CacheFailure('فشل في حفظ المرتجع: \$e'));
    }
  }
}
