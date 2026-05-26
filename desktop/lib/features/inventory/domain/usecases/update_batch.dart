import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';
import 'package:desktop/features/inventory/domain/repositories/batches_repository.dart';

class UpdateBatch {
  final BatchesRepository repository;

  UpdateBatch(this.repository);

  Future<Either<Failure, Batch>> call(Batch batch) async {
    return await repository.updateBatch(batch);
  }
}
