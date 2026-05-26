import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardDataUseCase;

  DashboardBloc({
    required this.getDashboardDataUseCase,
  }) : super(const DashboardInitialState()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoadingState());
    final result = await getDashboardDataUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (data) => emit(DashboardLoadedState(data)),
    );
  }

  Future<void> _onRefreshDashboard(RefreshDashboardEvent event, Emitter<DashboardState> emit) async {
    // Don't show loading indicator on refresh, keep current data visible
    final result = await getDashboardDataUseCase();
    result.fold(
      (failure) => emit(DashboardErrorState(failure.message)),
      (data) => emit(DashboardLoadedState(data)),
    );
  }
}
