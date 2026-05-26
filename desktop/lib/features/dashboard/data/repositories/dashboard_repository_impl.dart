import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:desktop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:desktop/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardRemoteDataSource remoteDataSource;
  final ConnectivityInfo connectivityInfo;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityInfo,
  });

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      // 1. Always load from local SQLite first (zero UI delay)
      final localData = await localDataSource.getDashboardData();
      return Right(localData);
    } catch (e) {
      return Left(CacheFailure('فشل في جلب بيانات لوحة التحكم: $e'));
    }
  }
}
