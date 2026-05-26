import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';

abstract class PurchaseReturnsEvent {
  const PurchaseReturnsEvent();
}

class LoadPurchaseReturnsEvent extends PurchaseReturnsEvent {
  const LoadPurchaseReturnsEvent();
}

class AddPurchaseReturnEvent extends PurchaseReturnsEvent {
  final PurchaseReturn purchaseReturn;
  const AddPurchaseReturnEvent(this.purchaseReturn);
}
