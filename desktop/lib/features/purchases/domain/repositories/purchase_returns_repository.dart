import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';

abstract class PurchaseReturnsRepository {
  Future<Either<Failure, List<PurchaseReturn>>> getPurchaseReturns();
  Future<Either<Failure, PurchaseReturn>> createPurchaseReturn(PurchaseReturn purchaseReturn);
}
