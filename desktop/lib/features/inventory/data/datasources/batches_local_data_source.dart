import 'package:sqflite/sqflite.dart';
import 'package:desktop/features/inventory/data/models/batch_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class BatchesLocalDataSource {
  Future<List<BatchModel>> getBatches();
  Future<void> cacheBatch(BatchModel batch);
  Future<void> updateBatch(BatchModel batch);
  Future<void> deleteBatch(String id);
}

class BatchesLocalDataSourceImpl implements BatchesLocalDataSource {
  final DatabaseService databaseService;

  BatchesLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<BatchModel>> getBatches() async {
    try {
      final db = await databaseService.database;
      // JOIN with medicines to resolve medicine_name for display
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT batches.*, medicines.name as medicine_name
        FROM batches
        LEFT JOIN medicines ON batches.medicine_id = medicines.id
        ORDER BY batches.rowid DESC
      ''');
      return maps.map((map) => BatchModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheBatch(BatchModel batch) async {
    try {
      final db = await databaseService.database;
      await db.insert(
        'batches',
        batch.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateBatch(BatchModel batch) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'batches',
        batch.toMap(),
        where: 'id = ?',
        whereArgs: [batch.id],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteBatch(String id) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'batches',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException();
    }
  }
}

class CacheException implements Exception {}
