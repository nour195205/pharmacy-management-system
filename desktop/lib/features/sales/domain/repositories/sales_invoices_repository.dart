import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';

abstract class SalesInvoicesRepository {
  Future<Either<Failure, List<SalesInvoice>>> getSalesInvoices();
  Future<Either<Failure, SalesInvoice>> createSalesInvoice(SalesInvoice invoice);
}
