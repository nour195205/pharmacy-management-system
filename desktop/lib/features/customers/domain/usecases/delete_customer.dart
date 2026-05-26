import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';

class DeleteCustomer {
  final CustomersRepository repository;

  DeleteCustomer(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCustomer(id);
  }
}
