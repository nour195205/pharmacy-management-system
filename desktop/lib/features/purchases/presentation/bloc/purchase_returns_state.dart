import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';

abstract class PurchaseReturnsState {
  const PurchaseReturnsState();
}

class PurchaseReturnsInitialState extends PurchaseReturnsState {
  const PurchaseReturnsInitialState();
}

class PurchaseReturnsLoadingState extends PurchaseReturnsState {
  const PurchaseReturnsLoadingState();
}

class PurchaseReturnsLoadedState extends PurchaseReturnsState {
  final List<PurchaseReturn> returns;
  const PurchaseReturnsLoadedState(this.returns);
}

class PurchaseReturnsErrorState extends PurchaseReturnsState {
  final String message;
  const PurchaseReturnsErrorState(this.message);
}

class PurchaseReturnOperationSuccessState extends PurchaseReturnsState {
  final String message;
  const PurchaseReturnOperationSuccessState(this.message);
}
