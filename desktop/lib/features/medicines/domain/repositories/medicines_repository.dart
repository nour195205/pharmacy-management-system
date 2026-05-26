import 'package:dartz/dartz.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';

abstract class MedicinesRepository {
  Future<Either<Failure, List<Medicine>>> getMedicines();
  Future<Either<Failure, Medicine>> createMedicine(Medicine medicine);
  Future<Either<Failure, Medicine>> updateMedicine(Medicine medicine);
  Future<Either<Failure, void>> deleteMedicine(String id);
}
