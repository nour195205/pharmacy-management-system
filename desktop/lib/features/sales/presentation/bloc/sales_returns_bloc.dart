import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/sales/domain/usecases/create_sales_return.dart';
import 'package:desktop/features/sales/domain/usecases/get_sales_returns.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_state.dart';

class SalesReturnsBloc extends Bloc<SalesReturnsEvent, SalesReturnsState> {
  final GetSalesReturns getSalesReturnsUseCase;
  final CreateSalesReturn createSalesReturnUseCase;

  SalesReturnsBloc({
    required this.getSalesReturnsUseCase,
    required this.createSalesReturnUseCase,
  }) : super(const SalesReturnsInitialState()) {
    on<LoadSalesReturnsEvent>(_onLoad);
    on<AddSalesReturnEvent>(_onAdd);
  }

  Future<void> _onLoad(LoadSalesReturnsEvent event, Emitter<SalesReturnsState> emit) async {
    emit(const SalesReturnsLoadingState());
    final result = await getSalesReturnsUseCase();
    result.fold(
      (failure) => emit(SalesReturnsErrorState(failure.message)),
      (returns) => emit(SalesReturnsLoadedState(returns)),
    );
  }

  Future<void> _onAdd(AddSalesReturnEvent event, Emitter<SalesReturnsState> emit) async {
    emit(const SalesReturnsLoadingState());
    final result = await createSalesReturnUseCase(event.salesReturn);
    result.fold(
      (failure) {
        emit(SalesReturnsErrorState(failure.message));
        add(const LoadSalesReturnsEvent());
      },
      (salesReturn) {
        emit(const SalesReturnOperationSuccessState('تم تسجيل مرتجع المبيعات بنجاح'));
        add(const LoadSalesReturnsEvent());
      },
    );
  }
}
