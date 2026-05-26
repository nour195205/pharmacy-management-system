import 'package:desktop/features/customers/domain/entities/customer.dart';

abstract class CustomersState {
  const CustomersState();
}

class CustomersInitialState extends CustomersState {
  const CustomersInitialState();
}

class CustomersLoadingState extends CustomersState {
  const CustomersLoadingState();
}

class CustomersLoadedState extends CustomersState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;

  const CustomersLoadedState({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery = '',
  });

  CustomersLoadedState copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomersLoadedState(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomersErrorState extends CustomersState {
  final String message;
  const CustomersErrorState(this.message);
}
