import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_returns_repository.dart';

class CreatePurchaseReturn {
  final PurchaseReturnsRepository repository;

  CreatePurchaseReturn(this.repository);

  Future<Either<Failure, PurchaseReturn>> call(PurchaseReturn purchaseReturn) async {
    return await repository.createPurchaseReturn(purchaseReturn);
  }
}
