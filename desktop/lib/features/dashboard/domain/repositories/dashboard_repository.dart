import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
}
