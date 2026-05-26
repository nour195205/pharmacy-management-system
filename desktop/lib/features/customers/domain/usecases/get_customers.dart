import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/domain/repositories/customers_repository.dart';

class GetCustomers {
  final CustomersRepository repository;

  GetCustomers(this.repository);

  Future<Either<Failure, List<Customer>>> call() async {
    return await repository.getCustomers();
  }
}
