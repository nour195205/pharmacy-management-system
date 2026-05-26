import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/sales/domain/usecases/create_sales_invoice.dart';
import 'package:desktop/features/sales/domain/usecases/get_sales_invoices.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_state.dart';

class SalesInvoicesBloc extends Bloc<SalesInvoicesEvent, SalesInvoicesState> {
  final GetSalesInvoices getSalesInvoicesUseCase;
  final CreateSalesInvoice createSalesInvoiceUseCase;

  SalesInvoicesBloc({
    required this.getSalesInvoicesUseCase,
    required this.createSalesInvoiceUseCase,
  }) : super(const SalesInvoicesInitialState()) {
    on<LoadSalesInvoicesEvent>(_onLoad);
    on<AddSalesInvoiceEvent>(_onAdd);
  }

  Future<void> _onLoad(LoadSalesInvoicesEvent event, Emitter<SalesInvoicesState> emit) async {
    emit(const SalesInvoicesLoadingState());
    final result = await getSalesInvoicesUseCase();
    result.fold(
      (failure) => emit(SalesInvoicesErrorState(failure.message)),
      (invoices) => emit(SalesInvoicesLoadedState(invoices)),
    );
  }

  Future<void> _onAdd(AddSalesInvoiceEvent event, Emitter<SalesInvoicesState> emit) async {
    emit(const SalesInvoicesLoadingState());
    final result = await createSalesInvoiceUseCase(event.invoice);
    result.fold(
      (failure) {
        emit(SalesInvoicesErrorState(failure.message));
        add(const LoadSalesInvoicesEvent()); // Reload data
      },
      (invoice) {
        emit(const SalesInvoiceOperationSuccessState('تم تسجيل فاتورة المبيعات بنجاح'));
        add(const LoadSalesInvoicesEvent());
      },
    );
  }
}
