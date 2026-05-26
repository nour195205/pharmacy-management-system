import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/sales/domain/repositories/sales_invoices_repository.dart';

class DeleteSalesInvoice {
  final SalesInvoicesRepository repository;

  DeleteSalesInvoice(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSalesInvoice(id);
  }
}
