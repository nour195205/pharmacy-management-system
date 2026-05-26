import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';

abstract class SalesInvoicesEvent {
  const SalesInvoicesEvent();
}

class LoadSalesInvoicesEvent extends SalesInvoicesEvent {
  const LoadSalesInvoicesEvent();
}

class AddSalesInvoiceEvent extends SalesInvoicesEvent {
  final SalesInvoice invoice;
  const AddSalesInvoiceEvent(this.invoice);
}

class UpdateSalesInvoiceEvent extends SalesInvoicesEvent {
  final SalesInvoice invoice;
  const UpdateSalesInvoiceEvent(this.invoice);
}

class DeleteSalesInvoiceEvent extends SalesInvoicesEvent {
  final String id;
  const DeleteSalesInvoiceEvent(this.id);
}
