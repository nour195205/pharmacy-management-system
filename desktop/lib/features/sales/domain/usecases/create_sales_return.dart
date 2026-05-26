import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';
import 'package:desktop/features/sales/domain/repositories/sales_returns_repository.dart';

class CreateSalesReturn {
  final SalesReturnsRepository repository;

  CreateSalesReturn(this.repository);

  Future<Either<Failure, SalesReturn>> call(SalesReturn salesReturn) async {
    return await repository.createSalesReturn(salesReturn);
  }
}
