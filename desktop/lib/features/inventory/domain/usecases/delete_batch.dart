import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/inventory/domain/repositories/batches_repository.dart';

class DeleteBatch {
  final BatchesRepository repository;

  DeleteBatch(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteBatch(id);
  }
}
