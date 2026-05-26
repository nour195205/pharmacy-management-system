import 'package:desktop/features/inventory/domain/entities/batch.dart';

abstract class BatchesState {
  const BatchesState();
}

class BatchesInitialState extends BatchesState {
  const BatchesInitialState();
}

class BatchesLoadingState extends BatchesState {
  const BatchesLoadingState();
}

class BatchesLoadedState extends BatchesState {
  final List<Batch> batches;
  final List<Batch> filteredBatches;
  final String searchQuery;
  final String? selectedMedicineId;
  final String? selectedExpiryStatus;

  const BatchesLoadedState({
    required this.batches,
    required this.filteredBatches,
    this.searchQuery = '',
    this.selectedMedicineId,
    this.selectedExpiryStatus,
  });

  BatchesLoadedState copyWith({
    List<Batch>? batches,
    List<Batch>? filteredBatches,
    String? searchQuery,
    String? Function()? selectedMedicineId,
    String? Function()? selectedExpiryStatus,
  }) {
    return BatchesLoadedState(
      batches: batches ?? this.batches,
      filteredBatches: filteredBatches ?? this.filteredBatches,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMedicineId: selectedMedicineId != null ? selectedMedicineId() : this.selectedMedicineId,
      selectedExpiryStatus: selectedExpiryStatus != null ? selectedExpiryStatus() : this.selectedExpiryStatus,
    );
  }
}

class BatchesErrorState extends BatchesState {
  final String message;
  const BatchesErrorState(this.message);
}
