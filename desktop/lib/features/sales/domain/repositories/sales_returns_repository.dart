import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';

abstract class SalesReturnsRepository {
  Future<Either<Failure, List<SalesReturn>>> getSalesReturns();
  Future<Either<Failure, SalesReturn>> createSalesReturn(SalesReturn salesReturn);
}
