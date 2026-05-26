import 'package:desktop/features/customers/domain/entities/customer.dart';

abstract class CustomersEvent {
  const CustomersEvent();
}

class LoadCustomersEvent extends CustomersEvent {
  const LoadCustomersEvent();
}

class AddCustomerEvent extends CustomersEvent {
  final Customer customer;
  const AddCustomerEvent(this.customer);
}

class EditCustomerEvent extends CustomersEvent {
  final Customer customer;
  const EditCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomersEvent {
  final String id;
  const DeleteCustomerEvent(this.id);
}

class SearchCustomersEvent extends CustomersEvent {
  final String query;
  const SearchCustomersEvent(this.query);
}
