import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/repositories/purchase_invoices_repository.dart';

class GetPurchaseInvoices {
  final PurchaseInvoicesRepository repository;

  GetPurchaseInvoices(this.repository);

  Future<Either<Failure, List<PurchaseInvoice>>> call() async {
    return await repository.getPurchaseInvoices();
  }
}
