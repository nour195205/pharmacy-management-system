import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/purchases/domain/usecases/create_purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/usecases/get_purchase_invoices.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_state.dart';

class PurchaseInvoicesBloc extends Bloc<PurchaseInvoicesEvent, PurchaseInvoicesState> {
  final GetPurchaseInvoices getPurchaseInvoicesUseCase;
  final CreatePurchaseInvoice createPurchaseInvoiceUseCase;

  PurchaseInvoicesBloc({
    required this.getPurchaseInvoicesUseCase,
    required this.createPurchaseInvoiceUseCase,
  }) : super(const PurchaseInvoicesInitialState()) {
    on<LoadPurchaseInvoicesEvent>(_onLoad);
    on<AddPurchaseInvoiceEvent>(_onAdd);
  }

  Future<void> _onLoad(LoadPurchaseInvoicesEvent event, Emitter<PurchaseInvoicesState> emit) async {
    emit(const PurchaseInvoicesLoadingState());
    final result = await getPurchaseInvoicesUseCase();
    result.fold(
      (failure) => emit(PurchaseInvoicesErrorState(failure.message)),
      (invoices) => emit(PurchaseInvoicesLoadedState(invoices)),
    );
  }

  Future<void> _onAdd(AddPurchaseInvoiceEvent event, Emitter<PurchaseInvoicesState> emit) async {
    emit(const PurchaseInvoicesLoadingState());
    final result = await createPurchaseInvoiceUseCase(event.invoice);
    result.fold(
      (failure) {
        emit(PurchaseInvoicesErrorState(failure.message));
        add(const LoadPurchaseInvoicesEvent()); // Reload data
      },
      (invoice) {
        emit(const PurchaseInvoiceOperationSuccessState('تم إضافة فاتورة المشتريات بنجاح'));
        add(const LoadPurchaseInvoicesEvent());
      },
    );
  }
}
