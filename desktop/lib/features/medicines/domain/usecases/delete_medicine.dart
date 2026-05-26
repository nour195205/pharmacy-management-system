import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/medicines/domain/repositories/medicines_repository.dart';

class DeleteMedicine {
  final MedicinesRepository repository;

  DeleteMedicine(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteMedicine(id);
  }
}
