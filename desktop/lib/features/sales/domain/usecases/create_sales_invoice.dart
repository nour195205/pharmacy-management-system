import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';
import 'package:desktop/features/sales/domain/repositories/sales_invoices_repository.dart';

class CreateSalesInvoice {
  final SalesInvoicesRepository repository;

  CreateSalesInvoice(this.repository);

  Future<Either<Failure, SalesInvoice>> call(SalesInvoice invoice) async {
    return await repository.createSalesInvoice(invoice);
  }
}
