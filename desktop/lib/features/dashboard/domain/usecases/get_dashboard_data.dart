import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:desktop/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardData {
  final DashboardRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardData>> call() async {
    return await repository.getDashboardData();
  }
}
