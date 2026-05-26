import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';
import 'package:desktop/features/medicines/domain/repositories/medicines_repository.dart';

class CreateMedicine {
  final MedicinesRepository repository;

  CreateMedicine(this.repository);

  Future<Either<Failure, Medicine>> call(Medicine medicine) async {
    return await repository.createMedicine(medicine);
  }
}
