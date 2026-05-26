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

      // Sync Suppliers
      try {
        final Response response = await _apiService.get('/suppliers');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List suppliers = responseData['data'];
          for (var item in suppliers) {
            final supplierMap = item as Map<String, dynamic>;
            final id = supplierMap['id'].toString();
            
            await db.insert('suppliers', {
              'id': id,
              'name': supplierMap['name'],
              'contact_info': supplierMap['contact_info'] ?? '',
              'address': supplierMap['address'] ?? '',
              'phone': supplierMap['phone'] ?? '',
              'email': supplierMap['email'] ?? '',
              'balance': supplierMap['balance'] != null 
                  ? double.tryParse(supplierMap['balance'].toString()) ?? 0.0
                  : 0.0,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      } catch (e) {
        debugPrint('Sync down suppliers error: $e');
      }

      // Sync Branches
      try {
        final Response response = await _apiService.get('/branches');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List branches = responseData['data'];
          for (var item in branches) {
            final branchMap = item as Map<String, dynamic>;
            final id = (branchMap['id'] as num).toInt();
            
            await db.insert('branches', {
              'id': id,
              'name': branchMap['name'],
              'location': branchMap['location'] ?? '',
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      } catch (e) {
        debugPrint('Sync down branches error: $e');
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

      // 3. Sync Batches
      try {
        final Response response = await _apiService.get('/batches');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List batches = responseData['data'];
          for (var item in batches) {
            final batchMap = item as Map<String, dynamic>;
            final id = batchMap['id'].toString();
            
            String medId = (batchMap['medicine_id'] ?? '').toString();
            if (batchMap['medicine'] != null && batchMap['medicine'] is Map) {
              medId = batchMap['medicine']['id'].toString();
            }

            int bId = 1;
            if (batchMap['branch'] != null && batchMap['branch'] is Map) {
              bId = (batchMap['branch']['id'] as num?)?.toInt() ?? 1;
            } else {
              bId = (batchMap['branch_id'] as num?)?.toInt() ?? 1;
            }
            
            await db.insert('batches', {
              'id': id,
              'medicine_id': medId,
              'batch_number': batchMap['batch_number']?.toString() ?? '',
              'manufacture_date': batchMap['manufacture_date']?.toString() ?? '',
              'expiry_date': batchMap['expiry_date']?.toString() ?? '',
              'quantity': batchMap['quantity'] != null 
                  ? double.tryParse(batchMap['quantity'].toString()) ?? 0.0
                  : 0.0,
              'purchase_price': batchMap['purchase_price'] != null 
                  ? int.tryParse(batchMap['purchase_price'].toString()) ?? 0
                  : 0,
              'selling_price': batchMap['selling_price'] != null 
                  ? int.tryParse(batchMap['selling_price'].toString()) ?? 0
                  : 0,
              'branch_id': bId,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      } catch (e) {
        debugPrint('Sync down batches error: $e');
      }

      // 4. Sync Sales Invoices (Sync down all invoices and their items)
      try {
        final Response response = await _apiService.get('/sales-invoices');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List invoices = responseData['data'];
          for (var item in invoices) {
            final invoiceMap = item as Map<String, dynamic>;
            final id = invoiceMap['id'].toString();
            
            final branchId = (invoiceMap['branch']?['id'] as num?)?.toInt() ?? 1;
            final customerId = invoiceMap['customer']?['id']?.toString();
            final createdBy = (invoiceMap['creator']?['id'] as num?)?.toInt() ?? 1;

            await db.insert('sales_invoices', {
              'id': id,
              'branch_id': branchId,
              'customer_id': customerId,
              'date': invoiceMap['date']?.toString() ?? '',
              'total': (invoiceMap['total'] as num?)?.toDouble() ?? 0.0,
              'status': invoiceMap['status']?.toString() ?? 'مدفوع',
              'payment_method': invoiceMap['payment_method']?.toString() ?? 'نقدا',
              'note': invoiceMap['note']?.toString(),
              'created_by': createdBy,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Sync items
            if (invoiceMap['items'] != null) {
              final List items = invoiceMap['items'];
              for (var it in items) {
                final itemMap = it as Map<String, dynamic>;
                final itemId = itemMap['id'].toString();
                final batchId = itemMap['batch']?['id']?.toString() ?? '';
                
                await db.insert('sales_invoice_items', {
                  'id': itemId,
                  'sales_invoice_id': id,
                  'batch_id': batchId,
                  'qty': (itemMap['quantity'] as num?)?.toInt() ?? 0,
                  'price': (itemMap['price'] as num?)?.toInt() ?? 0,
                }, conflictAlgorithm: ConflictAlgorithm.replace);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Sync down sales invoices error: $e');
      }

      // 5. Sync Sales Returns (Sync down all returns and their items)
      try {
        final Response response = await _apiService.get('/sales-returns');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List returns = responseData['data'];
          for (var item in returns) {
            final returnMap = item as Map<String, dynamic>;
            final id = returnMap['id'].toString();
            final salesInvoiceId = returnMap['sales_invoice']?['id']?.toString() ?? '';
            final createdBy = (returnMap['user']?['id'] as num?)?.toInt() ?? 1;

            await db.insert('sales_returns', {
              'id': id,
              'sales_invoice_id': salesInvoiceId,
              'date': returnMap['date']?.toString() ?? '',
              'total': (returnMap['total'] as num?)?.toDouble() ?? 0.0,
              'reason': returnMap['reason']?.toString(),
              'created_by': createdBy,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Sync items
            if (returnMap['items'] != null) {
              final List items = returnMap['items'];
              for (var it in items) {
                final itemMap = it as Map<String, dynamic>;
                final itemId = itemMap['id'].toString();
                final batchId = itemMap['batch']?['id']?.toString() ?? '';

                await db.insert('sales_return_items', {
                  'id': itemId,
                  'sales_return_id': id,
                  'batch_id': batchId,
                  'quantity': (itemMap['quantity'] as num?)?.toInt() ?? 0,
                  'selling_price': (itemMap['selling_price'] as num?)?.toDouble() ?? 0.0,
                  'total': (itemMap['total'] as num?)?.toDouble() ?? 0.0,
                }, conflictAlgorithm: ConflictAlgorithm.replace);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Sync down sales returns error: $e');
      }

      // 6. Sync Purchase Invoices (Sync down all invoices and their items)
      try {
        final Response response = await _apiService.get('/purchase-invoices');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List invoices = responseData['data'];
          for (var item in invoices) {
            final invoiceMap = item as Map<String, dynamic>;
            final id = invoiceMap['id'].toString();
            
            final branchId = (invoiceMap['branch']?['id'] as num?)?.toInt() ?? 1;
            final supplierId = invoiceMap['supplier']?['id']?.toString() ?? '';
            final userId = (invoiceMap['user']?['id'] as num?)?.toInt() ?? 1;

            await db.insert('purchase_invoices', {
              'id': id,
              'branch_id': branchId,
              'supplier_id': supplierId,
              'user_id': userId,
              'invoice_date': invoiceMap['invoice_date']?.toString() ?? '',
              'total_amount': (invoiceMap['total_amount'] as num?)?.toDouble() ?? 0.0,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Sync items
            if (invoiceMap['items'] != null) {
              final List items = invoiceMap['items'];
              for (var it in items) {
                final itemMap = it as Map<String, dynamic>;
                final itemId = itemMap['id'].toString();
                final batchId = itemMap['batch']?['id']?.toString() ?? '';
                
                await db.insert('purchase_invoice_items', {
                  'id': itemId,
                  'purchase_invoice_id': id,
                  'batch_id': batchId,
                  'qty': (itemMap['qty'] as num?)?.toInt() ?? 0,
                  'price': (itemMap['price'] as num?)?.toDouble() ?? 0.0,
                }, conflictAlgorithm: ConflictAlgorithm.replace);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Sync down purchase invoices error: $e');
      }

      // 7. Sync Purchase Returns (Sync down all returns and their items)
      try {
        final Response response = await _apiService.get('/purchase-returns');
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final List returns = responseData['data'];
          for (var item in returns) {
            final returnMap = item as Map<String, dynamic>;
            final id = returnMap['id'].toString();
            final purchaseInvoiceId = returnMap['purchase_invoice']?['id']?.toString() ?? '';
            final userId = (returnMap['user']?['id'] as num?)?.toInt() ?? 1;

            await db.insert('purchase_returns', {
              'id': id,
              'purchase_invoice_id': purchaseInvoiceId,
              'user_id': userId,
              'date': returnMap['date']?.toString() ?? '',
              'total': (returnMap['total'] as num?)?.toDouble() ?? 0.0,
              'reason': returnMap['reason']?.toString(),
              'created_by': (returnMap['created_by'] as num?)?.toInt() ?? 1,
              'is_synced': 1,
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Sync items
            if (returnMap['items'] != null) {
              final List items = returnMap['items'];
              for (var it in items) {
                final itemMap = it as Map<String, dynamic>;
                final itemId = itemMap['id'].toString();
                final batchId = itemMap['batch']?['id']?.toString() ?? '';

                await db.insert('purchase_return_items', {
                  'id': itemId,
                  'purchase_return_id': id,
                  'batch_id': batchId,
                  'quantity': (itemMap['quantity'] as num?)?.toInt() ?? 0,
                  'purchase_price': (itemMap['purchase_price'] as num?)?.toDouble() ?? 0.0,
                  'total': (itemMap['total'] as num?)?.toDouble() ?? 0.0,
                }, conflictAlgorithm: ConflictAlgorithm.replace);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Sync down purchase returns error: $e');
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
        await txn.rawUpdate(
          'UPDATE sales_returns SET sales_invoice_id = ? WHERE sales_invoice_id = ?',
          [serverId, localId],
        );
      }
      else if (tableName == 'sales_returns') {
        await txn.rawUpdate(
          'UPDATE sales_return_items SET sales_return_id = ? WHERE sales_return_id = ?',
          [serverId, localId],
        );
      }
      else if (tableName == 'purchase_invoices') {
        await txn.rawUpdate(
          'UPDATE purchase_invoice_items SET purchase_invoice_id = ? WHERE purchase_invoice_id = ?',
          [serverId, localId],
        );
        await txn.rawUpdate(
          'UPDATE purchase_returns SET purchase_invoice_id = ? WHERE purchase_invoice_id = ?',
          [serverId, localId],
        );
      }
      else if (tableName == 'purchase_returns') {
        await txn.rawUpdate(
          'UPDATE purchase_return_items SET purchase_return_id = ? WHERE purchase_return_id = ?',
          [serverId, localId],
        );
      }

      // 3. Update any subsequent items in the pending operations queue that reference the old localId
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
      case 'sales_returns':
        return '/sales-returns';
      case 'purchase_invoices':
        return '/purchase-invoices';
      case 'purchase_returns':
        return '/purchase-returns';
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
