import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_local_data_source.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_remote_data_source.dart';
import 'package:desktop/features/medicines/data/models/medicine_model.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';
import 'package:desktop/features/medicines/domain/repositories/medicines_repository.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';

class MedicinesRepositoryImpl implements MedicinesRepository {
  final MedicinesLocalDataSource localDataSource;
  final MedicinesRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;
  final DatabaseService databaseService;
  final SyncService syncService;

  MedicinesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
    required this.databaseService,
    required this.syncService,
  });

  @override
  Future<Either<Failure, List<Medicine>>> getMedicines() async {
    try {
      // 1. Always load local database cache first (Zero UI delay)
      final localMedicines = await localDataSource.getMedicines();

      // 2. Fetch server updates in background if connected
      _fetchServerUpdatesInBackground();

      return Right(localMedicines);
    } on CacheException {
      return const Left(CacheFailure('فشل في جلب البيانات من قاعدة البيانات المحلية'));
    }
  }

  void _fetchServerUpdatesInBackground() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      try {
        final remoteMedicines = await remoteDataSource.getMedicines();
        for (var model in remoteMedicines) {
          await localDataSource.cacheMedicine(model);
        }
      } catch (e) {
        // Suppress background sync exceptions to prevent disrupting UI experience
      }
    }
  }

  @override
  Future<Either<Failure, Medicine>> createMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    try {
      // 1. Store locally in SQLite immediately
      await localDataSource.cacheMedicine(MedicineModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Add to Pending Operations queue for background upload
      await databaseService.queueOperation(
        tableName: 'medicines',
        operationType: 'CREATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger queue sync in background if connected
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في حفظ الدواء محلياً'));
    }
  }

  @override
  Future<Either<Failure, Medicine>> updateMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);
    try {
      // 1. Save locally in SQLite immediately
      await localDataSource.updateMedicine(MedicineModel.fromEntity(model.copyWith(isSynced: false)));

      // 2. Add to Pending Operations queue
      await databaseService.queueOperation(
        tableName: 'medicines',
        operationType: 'UPDATE',
        recordId: model.id,
        payload: model.toJson(),
      );

      // 3. Trigger queue sync in background
      _triggerBackgroundSync();

      return Right(model);
    } on CacheException {
      return const Left(CacheFailure('فشل في تعديل الدواء محلياً'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine(String id) async {
    try {
      // 1. Delete from local SQLite immediately
      await localDataSource.deleteMedicine(id);

      // 2. Add to Pending Operations queue
      await databaseService.queueOperation(
        tableName: 'medicines',
        operationType: 'DELETE',
        recordId: id,
      );

      // 3. Trigger queue sync in background
      _triggerBackgroundSync();

      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('فشل في حذف الدواء محلياً'));
    }
  }

  void _triggerBackgroundSync() async {
    final isOnline = await connectivityInfo.isConnected;
    if (isOnline) {
      // Trigger execution of the pending operations queue async
      syncService.syncQueue();
    }
  }
}
