import 'package:desktop/features/sales/domain/entities/sales_return.dart';

abstract class SalesReturnsState {
  const SalesReturnsState();
}

class SalesReturnsInitialState extends SalesReturnsState {
  const SalesReturnsInitialState();
}

class SalesReturnsLoadingState extends SalesReturnsState {
  const SalesReturnsLoadingState();
}

class SalesReturnsLoadedState extends SalesReturnsState {
  final List<SalesReturn> returns;
  const SalesReturnsLoadedState(this.returns);
}

class SalesReturnsErrorState extends SalesReturnsState {
  final String message;
  const SalesReturnsErrorState(this.message);
}

class SalesReturnOperationSuccessState extends SalesReturnsState {
  final String message;
  const SalesReturnOperationSuccessState(this.message);
}
