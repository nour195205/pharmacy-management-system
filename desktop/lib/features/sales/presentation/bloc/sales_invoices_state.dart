import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';

abstract class SalesInvoicesState {
  const SalesInvoicesState();
}

class SalesInvoicesInitialState extends SalesInvoicesState {
  const SalesInvoicesInitialState();
}

class SalesInvoicesLoadingState extends SalesInvoicesState {
  const SalesInvoicesLoadingState();
}

class SalesInvoicesLoadedState extends SalesInvoicesState {
  final List<SalesInvoice> invoices;
  const SalesInvoicesLoadedState(this.invoices);
}

class SalesInvoicesErrorState extends SalesInvoicesState {
  final String message;
  const SalesInvoicesErrorState(this.message);
}

class SalesInvoiceOperationSuccessState extends SalesInvoicesState {
  final String message;
  const SalesInvoiceOperationSuccessState(this.message);
}
