import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';

abstract class CustomersRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, Customer>> createCustomer(Customer customer);
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
}
