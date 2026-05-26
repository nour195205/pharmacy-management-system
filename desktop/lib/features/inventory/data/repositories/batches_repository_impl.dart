import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/inventory/data/datasources/batches_local_data_source.dart';
import 'package:desktop/features/inventory/data/datasources/batches_remote_data_source.dart';
import 'package:desktop/features/inventory/data/models/batch_model.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';
import 'package:desktop/features/inventory/domain/repositories/batches_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class BatchesRepositoryImpl implements BatchesRepository {
  final BatchesLocalDataSource localDataSource;
  final BatchesRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  BatchesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<Batch>>> getBatches() async {
    try {
      // 1. Always load local database cache first (Zero UI delay)
      final localBatches = await localDataSource.getBatches();

      // 2. Fetch server updates in background if connected
      _fetchServerUpdatesInBackground();

      return Right(localBatches);
    } on CacheException {
      return const Left(CacheFailure('فشل في جلب التشغيلات من قاعدة البيانات المحلية'));
    }
  }

  void _fetchServerUpdatesInBackground() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      try {
        final remoteBatches = await remoteDataSource.getBatches();
        for (var model in remoteBatches) {
          await localDataSource.cacheBatch(model);
        }
      } catch (e) {
        // Suppress background sync exceptions to prevent disrupting UI experience
      }
    }
  }

  @override
  Future<Either<Failure, Batch>> createBatch(Batch batch) async {
    final model = BatchModel.fromEntity(batch);
    try {
      // 1. Store locally in SQLite immediately
      await localDataSource.cacheBatch(BatchModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Add to Pending Operations queue for background upload
      await databaseService.queueOperation(
        tableName: 'batches',
        operationType: 'CREATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger queue sync in background if connected
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في حفظ التشغيلة محلياً'));
    }
  }

  @override
  Future<Either<Failure, Batch>> updateBatch(Batch batch) async {
    final model = BatchModel.fromEntity(batch);
    try {
      // 1. Save locally in SQLite immediately
      await localDataSource.updateBatch(BatchModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Add to Pending Operations queue
      await databaseService.queueOperation(
        tableName: 'batches',
        operationType: 'UPDATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger queue sync in background
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في تعديل التشغيلة محلياً'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBatch(String id) async {
    try {
      // 1. Delete from local SQLite immediately
      await localDataSource.deleteBatch(id);

      // 2. Add to Pending Operations queue
      await databaseService.queueOperation(
        tableName: 'batches',
        operationType: 'DELETE',
        recordId: id,
      );

      // 3. Trigger queue sync in background
      _triggerBackgroundSync();

      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('فشل في حذف التشغيلة محلياً'));
    }
  }

  void _triggerBackgroundSync() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      syncService.syncQueue();
    }
  }
}
