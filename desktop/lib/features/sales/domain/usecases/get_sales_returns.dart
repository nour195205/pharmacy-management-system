import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';
import 'package:desktop/features/sales/domain/repositories/sales_returns_repository.dart';

class GetSalesReturns {
  final SalesReturnsRepository repository;

  GetSalesReturns(this.repository);

  Future<Either<Failure, List<SalesReturn>>> call() async {
    return await repository.getSalesReturns();
  }
}
