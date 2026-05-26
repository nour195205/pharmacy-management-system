import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/sales/domain/usecases/create_sales_invoice.dart';
import 'package:desktop/features/sales/domain/usecases/get_sales_invoices.dart';
import 'package:desktop/features/sales/domain/usecases/update_sales_invoice.dart';
import 'package:desktop/features/sales/domain/usecases/delete_sales_invoice.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_state.dart';

class SalesInvoicesBloc extends Bloc<SalesInvoicesEvent, SalesInvoicesState> {
  final GetSalesInvoices getSalesInvoicesUseCase;
  final CreateSalesInvoice createSalesInvoiceUseCase;
  final UpdateSalesInvoice updateSalesInvoiceUseCase;
  final DeleteSalesInvoice deleteSalesInvoiceUseCase;

  SalesInvoicesBloc({
    required this.getSalesInvoicesUseCase,
    required this.createSalesInvoiceUseCase,
    required this.updateSalesInvoiceUseCase,
    required this.deleteSalesInvoiceUseCase,
  }) : super(const SalesInvoicesInitialState()) {
    on<LoadSalesInvoicesEvent>(_onLoad);
    on<AddSalesInvoiceEvent>(_onAdd);
    on<UpdateSalesInvoiceEvent>(_onUpdate);
    on<DeleteSalesInvoiceEvent>(_onDelete);
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

  Future<void> _onUpdate(UpdateSalesInvoiceEvent event, Emitter<SalesInvoicesState> emit) async {
    emit(const SalesInvoicesLoadingState());
    final result = await updateSalesInvoiceUseCase(event.invoice);
    result.fold(
      (failure) {
        emit(SalesInvoicesErrorState(failure.message));
        add(const LoadSalesInvoicesEvent());
      },
      (invoice) {
        emit(const SalesInvoiceOperationSuccessState('تم تعديل فاتورة المبيعات بنجاح'));
        add(const LoadSalesInvoicesEvent());
      },
    );
  }

  Future<void> _onDelete(DeleteSalesInvoiceEvent event, Emitter<SalesInvoicesState> emit) async {
    emit(const SalesInvoicesLoadingState());
    final result = await deleteSalesInvoiceUseCase(event.id);
    result.fold(
      (failure) {
        emit(SalesInvoicesErrorState(failure.message));
        add(const LoadSalesInvoicesEvent());
      },
      (_) {
        emit(const SalesInvoiceOperationSuccessState('تم حذف فاتورة المبيعات بنجاح'));
        add(const LoadSalesInvoicesEvent());
      },
    );
  }
}
