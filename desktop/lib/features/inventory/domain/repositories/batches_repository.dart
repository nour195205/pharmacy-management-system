import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';

abstract class BatchesRepository {
  Future<Either<Failure, List<Batch>>> getBatches();
  Future<Either<Failure, Batch>> createBatch(Batch batch);
  Future<Either<Failure, Batch>> updateBatch(Batch batch);
  Future<Either<Failure, void>> deleteBatch(String id);
}
