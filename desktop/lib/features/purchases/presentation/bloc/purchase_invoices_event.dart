import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';

abstract class PurchaseInvoicesEvent {
  const PurchaseInvoicesEvent();
}

class LoadPurchaseInvoicesEvent extends PurchaseInvoicesEvent {
  const LoadPurchaseInvoicesEvent();
}

class AddPurchaseInvoiceEvent extends PurchaseInvoicesEvent {
  final PurchaseInvoice invoice;
  const AddPurchaseInvoiceEvent(this.invoice);
}
