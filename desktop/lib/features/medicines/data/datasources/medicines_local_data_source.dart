import 'package:sqflite/sqflite.dart';
import 'package:desktop/features/medicines/data/models/medicine_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class MedicinesLocalDataSource {
  Future<List<MedicineModel>> getMedicines();
  Future<void> cacheMedicine(MedicineModel medicine);
  Future<void> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String id);
}

class MedicinesLocalDataSourceImpl implements MedicinesLocalDataSource {
  final DatabaseService databaseService;

  MedicinesLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<MedicineModel>> getMedicines() async {
    try {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query('medicines');
      return maps.map((map) => MedicineModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException(); // Throw standard CacheException to be handled in repo
    }
  }

  @override
  Future<void> cacheMedicine(MedicineModel medicine) async {
    try {
      final db = await databaseService.database;
      await db.insert(
        'medicines',
        medicine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'medicines',
        medicine.toMap(),
        where: 'id = ?',
        whereArgs: [medicine.id],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteMedicine(String id) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'medicines',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException();
    }
  }
}

class CacheException implements Exception {}
