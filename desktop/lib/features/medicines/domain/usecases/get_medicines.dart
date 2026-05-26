import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';
import 'package:desktop/features/medicines/domain/repositories/medicines_repository.dart';

class GetMedicines {
  final MedicinesRepository repository;

  GetMedicines(this.repository);

  Future<Either<Failure, List<Medicine>>> call() async {
    return await repository.getMedicines();
  }
}
