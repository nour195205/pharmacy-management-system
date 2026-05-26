import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/purchases/domain/usecases/create_purchase_return.dart';
import 'package:desktop/features/purchases/domain/usecases/get_purchase_returns.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_state.dart';

class PurchaseReturnsBloc extends Bloc<PurchaseReturnsEvent, PurchaseReturnsState> {
  final GetPurchaseReturns getPurchaseReturnsUseCase;
  final CreatePurchaseReturn createPurchaseReturnUseCase;

  PurchaseReturnsBloc({
    required this.getPurchaseReturnsUseCase,
    required this.createPurchaseReturnUseCase,
  }) : super(const PurchaseReturnsInitialState()) {
    on<LoadPurchaseReturnsEvent>(_onLoad);
    on<AddPurchaseReturnEvent>(_onAdd);
  }

  Future<void> _onLoad(LoadPurchaseReturnsEvent event, Emitter<PurchaseReturnsState> emit) async {
    emit(const PurchaseReturnsLoadingState());
    final result = await getPurchaseReturnsUseCase();
    result.fold(
      (failure) => emit(PurchaseReturnsErrorState(failure.message)),
      (returns) => emit(PurchaseReturnsLoadedState(returns)),
    );
  }

  Future<void> _onAdd(AddPurchaseReturnEvent event, Emitter<PurchaseReturnsState> emit) async {
    emit(const PurchaseReturnsLoadingState());
    final result = await createPurchaseReturnUseCase(event.purchaseReturn);
    result.fold(
      (failure) {
        emit(PurchaseReturnsErrorState(failure.message));
        add(const LoadPurchaseReturnsEvent()); // Reload
      },
      (purchaseReturn) {
        emit(const PurchaseReturnOperationSuccessState('تم إضافة المرتجع بنجاح'));
        add(const LoadPurchaseReturnsEvent());
      },
    );
  }
}
