import 'package:sqflite/sqflite.dart';
import 'package:desktop/features/medicines/data/datasources/medicines_local_data_source.dart'; // CacheException resides here
import 'package:desktop/features/customers/data/models/customer_model.dart';
import 'package:desktop/services/database_service.dart';

abstract class CustomersLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> cacheCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

class CustomersLocalDataSourceImpl implements CustomersLocalDataSource {
  final DatabaseService databaseService;

  CustomersLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query('customers');
      return maps.map((map) => CustomerModel.fromMap(map)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheCustomer(CustomerModel customer) async {
    try {
      final db = await databaseService.database;
      await db.insert(
        'customers',
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException();
    }
  }
}
