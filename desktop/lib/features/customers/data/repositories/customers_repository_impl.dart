import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_local_data_source.dart'; // CacheException
import 'package:desktop/features/customers/data/models/customer_model.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';
import 'package:desktop/features/customers/data/datasources/customers_local_data_source.dart';
import 'package:desktop/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersLocalDataSource localDataSource;
  final CustomersRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  CustomersRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      // 1. Always load local cache first
      final localCustomers = await localDataSource.getCustomers();

      // 2. Fetch remote in background
      _fetchServerUpdatesInBackground();

      return Right(localCustomers);
    } on CacheException {
      return const Left(CacheFailure('فشل في جلب العملاء من قاعدة البيانات المحلية'));
    }
  }

  void _fetchServerUpdatesInBackground() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      try {
        final remoteCustomers = await remoteDataSource.getCustomers();
        for (var model in remoteCustomers) {
          await localDataSource.cacheCustomer(model);
        }
      } catch (e) {
        // Suppress background sync errors to avoid UI disruption
      }
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      // 1. Cache locally
      await localDataSource.cacheCustomer(CustomerModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Queue for background sync
      await databaseService.queueOperation(
        tableName: 'customers',
        operationType: 'CREATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger sync
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في حفظ بيانات العميل محلياً'));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    try {
      // 1. Update locally
      await localDataSource.updateCustomer(CustomerModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Queue operation
      await databaseService.queueOperation(
        tableName: 'customers',
        operationType: 'UPDATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger sync
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في تعديل بيانات العميل محلياً'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      // 1. Delete locally
      await localDataSource.deleteCustomer(id);

      // 2. Queue operation
      await databaseService.queueOperation(
        tableName: 'customers',
        operationType: 'DELETE',
        recordId: id,
      );

      // 3. Trigger sync
      _triggerBackgroundSync();

      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('فشل في حذف العميل محلياً'));
    }
  }

  void _triggerBackgroundSync() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      syncService.syncQueue();
    }
  }
}
