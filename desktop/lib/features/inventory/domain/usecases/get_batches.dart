import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';
import 'package:desktop/features/inventory/domain/repositories/batches_repository.dart';

class GetBatches {
  final BatchesRepository repository;

  GetBatches(this.repository);

  Future<Either<Failure, List<Batch>>> call() async {
    return await repository.getBatches();
  }
}
