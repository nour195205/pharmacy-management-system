import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';

abstract class PurchaseInvoicesState {
  const PurchaseInvoicesState();
}

class PurchaseInvoicesInitialState extends PurchaseInvoicesState {
  const PurchaseInvoicesInitialState();
}

class PurchaseInvoicesLoadingState extends PurchaseInvoicesState {
  const PurchaseInvoicesLoadingState();
}

class PurchaseInvoicesLoadedState extends PurchaseInvoicesState {
  final List<PurchaseInvoice> invoices;
  const PurchaseInvoicesLoadedState(this.invoices);
}

class PurchaseInvoicesErrorState extends PurchaseInvoicesState {
  final String message;
  const PurchaseInvoicesErrorState(this.message);
}

class PurchaseInvoiceOperationSuccessState extends PurchaseInvoicesState {
  final String message;
  const PurchaseInvoiceOperationSuccessState(this.message);
}
