import 'package:desktop/features/sales/domain/entities/sales_return.dart';

abstract class SalesReturnsEvent {
  const SalesReturnsEvent();
}

class LoadSalesReturnsEvent extends SalesReturnsEvent {
  const LoadSalesReturnsEvent();
}

class AddSalesReturnEvent extends SalesReturnsEvent {
  final SalesReturn salesReturn;
  const AddSalesReturnEvent(this.salesReturn);
}
