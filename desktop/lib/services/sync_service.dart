import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop/core/network/connectivity_info.dart';
import 'package:desktop/services/api_service.dart';
import 'package:desktop/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class SyncService {
  final DatabaseService _dbService;
  final ApiService _apiService;
  final ConnectivityInfo _connectivityInfo;
  
  bool _isSyncing = false;
  StreamSubscription<bool>? _networkSubscription;

  // Stream controller to notify UI of sync status updates
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncService(
    this._dbService,
    this._apiService,
    this._connectivityInfo,
  ) {
    // Listen to network changes and auto-sync when online
    _networkSubscription = _connectivityInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncQueue();
      }
    });
  }

  void dispose() {
    _networkSubscription?.cancel();
    _syncStatusController.close();
  }

  // Core Sync Up: Send local queue to Laravel server
  Future<void> syncQueue() async {
    if (_isSyncing) return;
    
    final online = await _connectivityInfo.isConnected;
    if (!online) {
      _syncStatusController.add(SyncStatus.offline);
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      final db = await _dbService.database;
      
      while (true) {
        // Read the oldest pending operation (FIFO)
        final List<Map<String, dynamic>> pending = await db.query(
          'pending_operations',
          orderBy: 'id ASC',
          limit: 1,
        );

        if (pending.isEmpty) {
          break; // Queue is empty, syncing done!
        }

        final operation = pending.first;
        final opId = operation['id'] as int;
        final tableName = operation['table_name'] as String;
        final opType = operation['operation_type'] as String;
        final recordId = operation['record_id'] as String;
        final payloadStr = operation['payload'] as String?;
        
        final Map<String, dynamic> payload = 
            payloadStr != null ? jsonDecode(payloadStr) : {};

        final endpoint = _getEndpointForTable(tableName);
        bool success = false;

        try {
          if (opType == 'CREATE') {
            // Remove 'id' if server generates it (Laravel standard)
            // But we keep it in payload if server supports custom UUIDs/IDs
            final Response response = await _apiService.post(endpoint, data: payload);
            
            // Laravel response should return the newly created record with its server ID
            final responseData = response.data;
            if (responseData != null && responseData['data'] != null) {
              final serverData = responseData['data'] as Map<String, dynamic>;
              final dynamic serverIdRaw = serverData['id'];
              
              if (serverIdRaw != null) {
                final String serverId = serverIdRaw.toString();
                // Reconcile ID: replace local temporary ID with server ID
                await _reconcileId(db, tableName, recordId, serverId);
              }
            }
            success = true;
          } 
          else if (opType == 'UPDATE') {
            await _apiService.put('$endpoint/$recordId', data: payload);
            await db.update(
              tableName,
              {'is_synced': 1},
              where: 'id = ?',
              whereArgs: [recordId],
            );
            success = true;
          } 
          else if (opType == 'DELETE') {
            await _apiService.delete('$endpoint/$recordId');
            success = true;
          }

          if (success) {
            // Delete operation from the sync queue
            await db.delete(
              'pending_operations',
              where: 'id = ?',
              whereArgs: [opId],
            );
          }
        } on Exception catch (e) {
          debugPrint('Sync failed for operation $opId: $e');
          // If it's a server/connection issue, stop processing queue to retry later
          break;
        }
      }
      
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  // Core Sync Down: Fetch latest data from server and overwrite/update local database
  Future<void> syncFromServer() async {
    final online = await _connectivityInfo.isConnected;
    if (!online) return;

    try {
      final db = await _dbService.database;

      // 1. Sync Customers
      try {
        final Response response = await _apiService.get('/customers');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List customers = responseData['data'];
          for (var item in customers) {
            final customerMap = item as Map<String, dynamic>;
            final id = customerMap['id'].toString();
            
            await db.insert('customers', {
              'id': id,
              'name': customerMap['name'],
              'phone': customerMap['phone'],
              'address': customerMap['address'],
              'credit_limit': customerMap['credit_limit'] != null 
                  ? double.tryParse(customerMap['credit_limit'].toString()) ?? 0.0
                  : 0.0,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      } catch (e) {
        debugPrint('Sync down customers error: $e');
      }

      // 2. Sync Medicines
      try {
        final Response response = await _apiService.get('/medicines');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List medicines = responseData['data'];
          for (var item in medicines) {
            final medicineMap = item as Map<String, dynamic>;
            final id = medicineMap['id'].toString();
            
            await db.insert('medicines', {
              'id': id,
              'name': medicineMap['name'],
              'category': medicineMap['category'] ?? 'عام',
              'description': medicineMap['description'],
              'barcode': medicineMap['barcode'],
              'unit': medicineMap['unit'] ?? 'علبه',
              'price': medicineMap['price'] != null 
                  ? int.tryParse(medicineMap['price'].toString()) ?? 0
                  : 0,
              'reorder_level': medicineMap['reorder_level'],
              'is_active': (medicineMap['is_active'] == true || medicineMap['is_active'] == 1) ? 1 : 0,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      } catch (e) {
        debugPrint('Sync down medicines error: $e');
      }

      // Notify UI
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      debugPrint('Sync down error: $e');
    }
  }

  // ID Reconciliation helper: Updates local database references from local temp ID to remote server ID
  Future<void> _reconcileId(
    dynamic db,
    String tableName,
    String localId,
    String serverId,
  ) async {
    await db.transaction((txn) async {
      // 1. Update the record ID in its own table and set is_synced = 1
      await txn.rawUpdate(
        'UPDATE $tableName SET id = ?, is_synced = 1 WHERE id = ?',
        [serverId, localId],
      );

      // 2. Update foreign key references in other tables
      if (tableName == 'customers') {
        await txn.rawUpdate(
          'UPDATE sales_invoices SET customer_id = ? WHERE customer_id = ?',
          [serverId, localId],
        );
      } 
      else if (tableName == 'medicines') {
        await txn.rawUpdate(
          'UPDATE batches SET medicine_id = ? WHERE medicine_id = ?',
          [serverId, localId],
        );
      } 
      else if (tableName == 'batches') {
        await txn.rawUpdate(
          'UPDATE sales_invoice_items SET batch_id = ? WHERE batch_id = ?',
          [serverId, localId],
        );
      }
      else if (tableName == 'sales_invoices') {
        await txn.rawUpdate(
          'UPDATE sales_invoice_items SET sales_invoice_id = ? WHERE sales_invoice_id = ?',
          [serverId, localId],
        );
      }

      // 3. Update any subsequent items in the pending operations queue that reference the old localId
      // This handles cases where an update/delete of this record is already queued
      await txn.rawUpdate(
        "UPDATE pending_operations SET record_id = ? WHERE table_name = ? AND record_id = ?",
        [serverId, tableName, localId],
      );
    });
  }

  String _getEndpointForTable(String tableName) {
    switch (tableName) {
      case 'medicines':
        return '/medicines';
      case 'customers':
        return '/customers';
      case 'suppliers':
        return '/suppliers';
      case 'sales_invoices':
        return '/sales-invoices';
      case 'batches':
        return '/batches';
      default:
        throw Exception('Unknown table for synchronization: $tableName');
    }
  }
}

enum SyncStatus {
  offline,
  syncing,
  synced,
  error,
}
