import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';
import 'package:desktop/features/inventory/domain/usecases/create_batch.dart';
import 'package:desktop/features/inventory/domain/usecases/delete_batch.dart';
import 'package:desktop/features/inventory/domain/usecases/get_batches.dart';
import 'package:desktop/features/inventory/domain/usecases/update_batch.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_event.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_state.dart';

class BatchesBloc extends Bloc<BatchesEvent, BatchesState> {
  final GetBatches getBatchesUseCase;
  final CreateBatch createBatchUseCase;
  final UpdateBatch updateBatchUseCase;
  final DeleteBatch deleteBatchUseCase;

  BatchesBloc({
    required this.getBatchesUseCase,
    required this.createBatchUseCase,
    required this.updateBatchUseCase,
    required this.deleteBatchUseCase,
  }) : super(const BatchesInitialState()) {
    on<LoadBatchesEvent>(_onLoadBatches);
    on<AddBatchEvent>(_onAddBatch);
    on<EditBatchEvent>(_onEditBatch);
    on<DeleteBatchEvent>(_onDeleteBatch);
    on<SearchBatchesEvent>(_onSearchBatches);
    on<FilterBatchesEvent>(_onFilterBatches);
  }

  Future<void> _onLoadBatches(LoadBatchesEvent event, Emitter<BatchesState> emit) async {
    emit(const BatchesLoadingState());
    final result = await getBatchesUseCase();
    result.fold(
      (failure) => emit(BatchesErrorState(failure.message)),
      (batches) => emit(BatchesLoadedState(
        batches: batches,
        filteredBatches: batches,
      )),
    );
  }

  Future<void> _onAddBatch(AddBatchEvent event, Emitter<BatchesState> emit) async {
    final result = await createBatchUseCase(event.batch);
    result.fold(
      (failure) => emit(BatchesErrorState(failure.message)),
      (newBatch) {
        if (state is BatchesLoadedState) {
          final currentState = state as BatchesLoadedState;
          final updatedList = List<Batch>.from(currentState.batches)..add(newBatch);
          emit(currentState.copyWith(
            batches: updatedList,
            filteredBatches: _applyFilters(
              updatedList,
              currentState.searchQuery,
              currentState.selectedMedicineId,
              currentState.selectedExpiryStatus,
            ),
          ));
        } else {
          add(const LoadBatchesEvent());
        }
      },
    );
  }

  Future<void> _onEditBatch(EditBatchEvent event, Emitter<BatchesState> emit) async {
    final result = await updateBatchUseCase(event.batch);
    result.fold(
      (failure) => emit(BatchesErrorState(failure.message)),
      (updatedBatch) {
        if (state is BatchesLoadedState) {
          final currentState = state as BatchesLoadedState;
          final updatedList = currentState.batches.map((b) {
            return b.id == updatedBatch.id ? updatedBatch : b;
          }).toList();
          emit(currentState.copyWith(
            batches: updatedList,
            filteredBatches: _applyFilters(
              updatedList,
              currentState.searchQuery,
              currentState.selectedMedicineId,
              currentState.selectedExpiryStatus,
            ),
          ));
        } else {
          add(const LoadBatchesEvent());
        }
      },
    );
  }

  Future<void> _onDeleteBatch(DeleteBatchEvent event, Emitter<BatchesState> emit) async {
    final result = await deleteBatchUseCase(event.id);
    result.fold(
      (failure) => emit(BatchesErrorState(failure.message)),
      (_) {
        if (state is BatchesLoadedState) {
          final currentState = state as BatchesLoadedState;
          final updatedList = currentState.batches.where((b) => b.id != event.id).toList();
          emit(currentState.copyWith(
            batches: updatedList,
            filteredBatches: _applyFilters(
              updatedList,
              currentState.searchQuery,
              currentState.selectedMedicineId,
              currentState.selectedExpiryStatus,
            ),
          ));
        } else {
          add(const LoadBatchesEvent());
        }
      },
    );
  }

  void _onSearchBatches(SearchBatchesEvent event, Emitter<BatchesState> emit) {
    if (state is BatchesLoadedState) {
      final currentState = state as BatchesLoadedState;
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredBatches: _applyFilters(
          currentState.batches,
          event.query,
          currentState.selectedMedicineId,
          currentState.selectedExpiryStatus,
        ),
      ));
    }
  }

  void _onFilterBatches(FilterBatchesEvent event, Emitter<BatchesState> emit) {
    if (state is BatchesLoadedState) {
      final currentState = state as BatchesLoadedState;
      emit(currentState.copyWith(
        selectedMedicineId: () => event.medicineId,
        selectedExpiryStatus: () => event.expiryStatus,
        filteredBatches: _applyFilters(
          currentState.batches,
          currentState.searchQuery,
          event.medicineId,
          event.expiryStatus,
        ),
      ));
    }
  }

  List<Batch> _applyFilters(
    List<Batch> list,
    String query,
    String? medicineId,
    String? expiryStatus,
  ) {
    var filtered = list;

    // 1. Filter by medicine
    if (medicineId != null && medicineId.isNotEmpty) {
      filtered = filtered.where((b) => b.medicineId == medicineId).toList();
    }

    // 2. Filter by expiry status
    if (expiryStatus != null && expiryStatus.isNotEmpty) {
      final now = DateTime.now();
      final soon = now.add(const Duration(days: 90));
      filtered = filtered.where((b) {
        final expiry = DateTime.tryParse(b.expiryDate);
        if (expiry == null) return false;
        switch (expiryStatus) {
          case 'expired':
            return expiry.isBefore(now);
          case 'expiring_soon':
            return expiry.isAfter(now) && expiry.isBefore(soon);
          case 'valid':
            return expiry.isAfter(soon);
          default:
            return true;
        }
      }).toList();
    }

    // 3. Filter by search query
    if (query.trim().isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((b) {
        final nameMatch = b.medicineName?.toLowerCase().contains(lowerQuery) ?? false;
        final batchMatch = b.batchNumber.toLowerCase().contains(lowerQuery);
        return nameMatch || batchMatch;
      }).toList();
    }

    return filtered;
  }
}
