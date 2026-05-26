import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';

abstract class PurchaseInvoicesRepository {
  Future<Either<Failure, List<PurchaseInvoice>>> getPurchaseInvoices();
  Future<Either<Failure, PurchaseInvoice>> createPurchaseInvoice(PurchaseInvoice invoice);
}
