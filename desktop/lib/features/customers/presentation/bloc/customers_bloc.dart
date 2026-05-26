import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/domain/usecases/create_customer.dart';
import 'package:desktop/features/customers/domain/usecases/delete_customer.dart';
import 'package:desktop/features/customers/domain/usecases/get_customers.dart';
import 'package:desktop/features/customers/domain/usecases/update_customer.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_event.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetCustomers getCustomersUseCase;
  final CreateCustomer createCustomerUseCase;
  final UpdateCustomer updateCustomerUseCase;
  final DeleteCustomer deleteCustomerUseCase;

  CustomersBloc({
    required this.getCustomersUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(const CustomersInitialState()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<EditCustomerEvent>(_onEditCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<SearchCustomersEvent>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(LoadCustomersEvent event, Emitter<CustomersState> emit) async {
    emit(const CustomersLoadingState());
    final result = await getCustomersUseCase();
    result.fold(
      (failure) => emit(CustomersErrorState(failure.message)),
      (customers) => emit(CustomersLoadedState(
        customers: customers,
        filteredCustomers: customers,
      )),
    );
  }

  Future<void> _onAddCustomer(AddCustomerEvent event, Emitter<CustomersState> emit) async {
    final result = await createCustomerUseCase(event.customer);
    result.fold(
      (failure) => emit(CustomersErrorState(failure.message)),
      (newCustomer) {
        if (state is CustomersLoadedState) {
          final currentState = state as CustomersLoadedState;
          final updatedList = List<Customer>.from(currentState.customers)..add(newCustomer);
          emit(currentState.copyWith(
            customers: updatedList,
            filteredCustomers: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadCustomersEvent());
        }
      },
    );
  }

  Future<void> _onEditCustomer(EditCustomerEvent event, Emitter<CustomersState> emit) async {
    final result = await updateCustomerUseCase(event.customer);
    result.fold(
      (failure) => emit(CustomersErrorState(failure.message)),
      (updatedCustomer) {
        if (state is CustomersLoadedState) {
          final currentState = state as CustomersLoadedState;
          final updatedList = currentState.customers.map((c) {
            return c.id == updatedCustomer.id ? updatedCustomer : c;
          }).toList();
          emit(currentState.copyWith(
            customers: updatedList,
            filteredCustomers: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadCustomersEvent());
        }
      },
    );
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomersState> emit) async {
    final result = await deleteCustomerUseCase(event.id);
    result.fold(
      (failure) => emit(CustomersErrorState(failure.message)),
      (_) {
        if (state is CustomersLoadedState) {
          final currentState = state as CustomersLoadedState;
          final updatedList = currentState.customers.where((c) => c.id != event.id).toList();
          emit(currentState.copyWith(
            customers: updatedList,
            filteredCustomers: _applySearch(updatedList, currentState.searchQuery),
          ));
        } else {
          add(const LoadCustomersEvent());
        }
      },
    );
  }

  void _onSearchCustomers(SearchCustomersEvent event, Emitter<CustomersState> emit) {
    if (state is CustomersLoadedState) {
      final currentState = state as CustomersLoadedState;
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredCustomers: _applySearch(currentState.customers, event.query),
      ));
    }
  }

  List<Customer> _applySearch(List<Customer> list, String query) {
    if (query.trim().isEmpty) return list;
    final lowerQuery = query.toLowerCase();
    return list.where((c) {
      final nameMatch = c.name.toLowerCase().contains(lowerQuery);
      final phoneMatch = c.phone?.toLowerCase().contains(lowerQuery) ?? false;
      final addressMatch = c.address?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatch || phoneMatch || addressMatch;
    }).toList();
  }
}
