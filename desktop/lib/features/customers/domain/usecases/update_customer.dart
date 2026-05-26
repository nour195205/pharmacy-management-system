import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';

class UpdateCustomer {
  final CustomersRepository repository;

  UpdateCustomer(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    return await repository.updateCustomer(customer);
  }
}
