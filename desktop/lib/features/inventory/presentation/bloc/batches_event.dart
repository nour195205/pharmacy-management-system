import 'package:desktop/features/inventory/domain/entities/batch.dart';

abstract class BatchesEvent {
  const BatchesEvent();
}

class LoadBatchesEvent extends BatchesEvent {
  const LoadBatchesEvent();
}

class AddBatchEvent extends BatchesEvent {
  final Batch batch;
  const AddBatchEvent(this.batch);
}

class EditBatchEvent extends BatchesEvent {
  final Batch batch;
  const EditBatchEvent(this.batch);
}

class DeleteBatchEvent extends BatchesEvent {
  final String id;
  const DeleteBatchEvent(this.id);
}

class SearchBatchesEvent extends BatchesEvent {
  final String query;
  const SearchBatchesEvent(this.query);
}

class FilterBatchesEvent extends BatchesEvent {
  final String? medicineId;
  final String? expiryStatus; // 'expired', 'expiring_soon', 'valid', null
  const FilterBatchesEvent({this.medicineId, this.expiryStatus});
}
