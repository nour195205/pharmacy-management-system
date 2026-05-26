import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';

class CreateCustomer {
  final CustomersRepository repository;

  CreateCustomer(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    return await repository.createCustomer(customer);
  }
}
