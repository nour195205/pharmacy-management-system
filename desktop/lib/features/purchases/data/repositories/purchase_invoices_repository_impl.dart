import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_invoices_local_data_source.dart';
import 'package:desktop/features/purchases/data/datasources/purchase_invoices_remote_data_source.dart';
import 'package:desktop/features/purchases/data/models/purchase_invoice_model.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_invoices_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class PurchaseInvoicesRepositoryImpl implements PurchaseInvoicesRepository {
  final PurchaseInvoicesLocalDataSource localDataSource;
  final PurchaseInvoicesRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  PurchaseInvoicesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<PurchaseInvoice>>> getPurchaseInvoices() async {
    try {
      final localInvoices = await localDataSource.getPurchaseInvoices();
      return Right(localInvoices);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب فواتير المشتريات من القاعدة المحلية: \$e'));
    }
  }

  @override
  Future<Either<Failure, PurchaseInvoice>> createPurchaseInvoice(PurchaseInvoice invoice) async {
    try {
      final invoiceModel = PurchaseInvoiceModel(
        id: invoice.id,
        branchId: invoice.branchId,
        supplierId: invoice.supplierId,
        supplierName: invoice.supplierName,
        userId: invoice.userId,
        invoiceDate: invoice.invoiceDate,
        totalAmount: invoice.totalAmount,
        items: invoice.items,
      );

      // 1. Create locally (this handles invoices, items, and batches creation inside sqlite)
      final createdInvoice = await localDataSource.createPurchaseInvoice(invoiceModel);

      // 2. Queue for remote sync
      await databaseService.queueOperation(
        tableName: 'purchase_invoices',
        operationType: 'CREATE',
        recordId: createdInvoice.id,
        payload: createdInvoice.toJson(), // Send payload that Laravel expects
      );

      // 3. Try to sync immediately if online
      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return Right(createdInvoice);
    } catch (e) {
      return Left(CacheFailure('فشل في حفظ فاتورة المشتريات: \$e'));
    }
  }
}
