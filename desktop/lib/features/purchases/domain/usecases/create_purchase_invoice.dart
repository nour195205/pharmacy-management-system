import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_invoices_repository.dart';

class CreatePurchaseInvoice {
  final PurchaseInvoicesRepository repository;

  CreatePurchaseInvoice(this.repository);

  Future<Either<Failure, PurchaseInvoice>> call(PurchaseInvoice invoice) async {
    return await repository.createPurchaseInvoice(invoice);
  }
}
