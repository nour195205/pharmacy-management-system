import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/sales/data/datasources/sales_invoices_local_data_source.dart';
import 'package:desktop/features/sales/data/datasources/sales_invoices_remote_data_source.dart';
import 'package:desktop/features/sales/data/models/sales_invoice_model.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';
import 'package:desktop/features/sales/domain/repositories/sales_invoices_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class SalesInvoicesRepositoryImpl implements SalesInvoicesRepository {
  final SalesInvoicesLocalDataSource localDataSource;
  final SalesInvoicesRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  SalesInvoicesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<SalesInvoice>>> getSalesInvoices() async {
    try {
      final localInvoices = await localDataSource.getSalesInvoices();
      return Right(localInvoices);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب فواتير المبيعات محلياً: $e'));
    }
  }

  @override
  Future<Either<Failure, SalesInvoice>> createSalesInvoice(SalesInvoice invoice) async {
    try {
      final invoiceModel = SalesInvoiceModel(
        id: invoice.id,
        branchId: invoice.branchId,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        date: invoice.date,
        total: invoice.total,
        status: invoice.status,
        paymentMethod: invoice.paymentMethod,
        note: invoice.note,
        createdBy: invoice.createdBy,
        items: invoice.items,
      );

      final createdInvoice = await localDataSource.createSalesInvoice(invoiceModel);

      // Queue sync
      await databaseService.queueOperation(
        tableName: 'sales_invoices',
        operationType: 'CREATE',
        recordId: createdInvoice.id,
        payload: createdInvoice.toJson(),
      );

      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return Right(createdInvoice);
    } catch (e) {
      return Left(CacheFailure('فشل في إنشاء فاتورة مبيعات: $e'));
    }
  }

  @override
  Future<Either<Failure, SalesInvoice>> updateSalesInvoice(SalesInvoice invoice) async {
    try {
      final invoiceModel = SalesInvoiceModel(
        id: invoice.id,
        branchId: invoice.branchId,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        date: invoice.date,
        total: invoice.total,
        status: invoice.status,
        paymentMethod: invoice.paymentMethod,
        note: invoice.note,
        createdBy: invoice.createdBy,
        items: invoice.items,
        isSynced: invoice.isSynced,
        createdAt: invoice.createdAt,
      );

      final updatedInvoice = await localDataSource.updateSalesInvoice(invoiceModel);

      // Queue sync
      await databaseService.queueOperation(
        tableName: 'sales_invoices',
        operationType: 'UPDATE',
        recordId: updatedInvoice.id,
        payload: updatedInvoice.toJson(),
      );

      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return Right(updatedInvoice);
    } catch (e) {
      return Left(CacheFailure('فشل في تعديل فاتورة مبيعات: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSalesInvoice(String id) async {
    try {
      await localDataSource.deleteSalesInvoice(id);

      // Queue sync
      await databaseService.queueOperation(
        tableName: 'sales_invoices',
        operationType: 'DELETE',
        recordId: id,
      );

      if (await connectivityInfo.isConnected) {
        syncService.syncQueue();
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('فشل في حذف فاتورة مبيعات: $e'));
    }
  }
}
