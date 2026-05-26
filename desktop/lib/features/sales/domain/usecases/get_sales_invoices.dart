import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';
import 'package:desktop/features/sales/domain/repositories/sales_invoices_repository.dart';

class GetSalesInvoices {
  final SalesInvoicesRepository repository;

  GetSalesInvoices(this.repository);

  Future<Either<Failure, List<SalesInvoice>>> call() async {
    return await repository.getSalesInvoices();
  }
}
