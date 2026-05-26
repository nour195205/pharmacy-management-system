import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_returns_repository.dart';

class GetPurchaseReturns {
  final PurchaseReturnsRepository repository;

  GetPurchaseReturns(this.repository);

  Future<Either<Failure, List<PurchaseReturn>>> call() async {
    return await repository.getPurchaseReturns();
  }
}
