import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:desktop/core/utils/constants.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationSupportDirectory();
    final path = join(directory.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Suppliers Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_info TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        balance REAL DEFAULT 0.0,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 2. Customers Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        credit_limit REAL DEFAULT 0.0,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 3. Medicines Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        barcode TEXT,
        unit TEXT NOT NULL, -- 'شريط', 'علبه', 'زجاجه'
        price INTEGER NOT NULL,
        reorder_level TEXT,
        is_active INTEGER DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 4. Batches Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE batches (
        id TEXT PRIMARY KEY,
        medicine_id TEXT NOT NULL,
        batch_number TEXT NOT NULL,
        manufacture_date TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        quantity REAL NOT NULL,
        purchase_price INTEGER NOT NULL,
        selling_price INTEGER NOT NULL,
        branch_id INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (medicine_id) REFERENCES medicines (id) ON DELETE CASCADE
      )
    ''');

    // Purchase Invoices
    await db.execute('''
      CREATE TABLE purchase_invoices (
        id TEXT PRIMARY KEY,
        branch_id INTEGER NOT NULL,
        supplier_id TEXT NOT NULL,
        user_id INTEGER NOT NULL DEFAULT 1,
        invoice_date TEXT NOT NULL,
        total_amount REAL NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE
      )
    ''');

    // Purchase Invoice Items
    await db.execute('''
      CREATE TABLE purchase_invoice_items (
        id TEXT PRIMARY KEY,
        purchase_invoice_id TEXT NOT NULL,
        batch_id TEXT NOT NULL,
        qty INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (purchase_invoice_id) REFERENCES purchase_invoices (id) ON DELETE CASCADE,
        FOREIGN KEY (batch_id) REFERENCES batches (id) ON DELETE CASCADE
      )
    ''');

    // Purchase Returns
    await db.execute('''
      CREATE TABLE purchase_returns (
        id TEXT PRIMARY KEY,
        purchase_invoice_id TEXT NOT NULL,
        user_id INTEGER NOT NULL DEFAULT 1,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        reason TEXT,
        created_by INTEGER NOT NULL DEFAULT 1,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (purchase_invoice_id) REFERENCES purchase_invoices (id) ON DELETE CASCADE
      )
    ''');

    // Purchase Return Items
    await db.execute('''
      CREATE TABLE purchase_return_items (
        id TEXT PRIMARY KEY,
        purchase_return_id TEXT NOT NULL,
        batch_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (purchase_return_id) REFERENCES purchase_returns (id) ON DELETE CASCADE,
        FOREIGN KEY (batch_id) REFERENCES batches (id) ON DELETE CASCADE
      )
    ''');

    // 5. Sales Invoices Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE sales_invoices (
        id TEXT PRIMARY KEY,
        branch_id INTEGER NOT NULL,
        customer_id TEXT,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'مدفوع', -- 'مدفوع', 'معلق', 'ملغى'
        payment_method TEXT NOT NULL DEFAULT 'نقدا', -- 'نقدا', 'بطاقة', 'أخرى'
        note TEXT,
        created_by INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL
      )
    ''');

    // 6. Sales Invoice Items Table (Matches Laravel schema)
    await db.execute('''
      CREATE TABLE sales_invoice_items (
        id TEXT PRIMARY KEY,
        sales_invoice_id TEXT NOT NULL,
        batch_id TEXT NOT NULL,
        qty INTEGER NOT NULL,
        price INTEGER NOT NULL,
        FOREIGN KEY (sales_invoice_id) REFERENCES sales_invoices (id) ON DELETE CASCADE,
        FOREIGN KEY (batch_id) REFERENCES batches (id) ON DELETE CASCADE
      )
    ''');

    // 7. Sync Queue Table
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation_type TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE'
        record_id TEXT NOT NULL,
        payload TEXT, -- JSON payload of request body
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> queueOperation({
    required String tableName,
    required String operationType,
    required String recordId,
    Map<String, dynamic>? payload,
  }) async {
    final db = await database;
    await db.insert('pending_operations', {
      'table_name': tableName,
      'operation_type': operationType,
      'record_id': recordId,
      'payload': payload != null ? jsonEncode(payload) : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearDatabase() async {
    final db = await database;
    final batch = db.batch();
    batch.delete('sales_invoice_items');
    batch.delete('sales_invoices');
    batch.delete('purchase_return_items');
    batch.delete('purchase_returns');
    batch.delete('purchase_invoice_items');
    batch.delete('purchase_invoices');
    batch.delete('batches');
    batch.delete('medicines');
    batch.delete('customers');
    batch.delete('suppliers');
    batch.delete('pending_operations');
    await batch.commit();
  }
}
