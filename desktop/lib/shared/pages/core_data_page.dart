import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/features/customers/presentation/pages/customers_page.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/services/sync_service.dart';
import 'package:desktop/injection_container.dart' as di;

class CoreDataPage extends StatefulWidget {
  const CoreDataPage({super.key});

  @override
  State<CoreDataPage> createState() => _CoreDataPageState();
}

class _CoreDataPageState extends State<CoreDataPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final branches = await db.query('branches');
    final suppliers = await db.query('suppliers');

    setState(() {
      _branches = branches;
      _suppliers = suppliers;
      _isLoading = false;
    });
  }

  Future<void> _addBranch(String name, String location) async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    // Insert locally
    final int tempId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final now = DateTime.now().toIso8601String();

    await db.insert('branches', {
      'id': tempId,
      'name': name,
      'location': location,
      'is_synced': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Queue sync
    await dbService.queueOperation(
      tableName: 'branches',
      operationType: 'CREATE',
      recordId: tempId.toString(),
      payload: {
        'name': name,
        'location': location,
      },
    );

    _loadData();
    di.sl<SyncService>().syncQueue();
  }

  Future<void> _addSupplier(String name, String contact, String address, String phone, String email) async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;
    final String uuid = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    await db.insert('suppliers', {
      'id': uuid,
      'name': name,
      'contact_info': contact,
      'address': address,
      'phone': phone,
      'email': email,
      'balance': 0.0,
      'is_synced': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Queue sync
    await dbService.queueOperation(
      tableName: 'suppliers',
      operationType: 'CREATE',
      recordId: uuid,
      payload: {
        'name': name,
        'contact_info': contact,
        'address': address,
        'phone': phone,
        'email': email,
      },
    );

    _loadData();
    di.sl<SyncService>().syncQueue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات الأساسية والمراجع'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.slate600,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'الفروع', icon: Icon(LucideIcons.gitMerge)),
            Tab(text: 'الموردين', icon: Icon(LucideIcons.truck)),
            Tab(text: 'العملاء', icon: Icon(LucideIcons.users)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBranchesTab(),
          _buildSuppliersTab(),
          const CustomersPage(hideAppBar: true),
        ],
      ),
    );
  }

  Widget _buildBranchesTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('قائمة الفروع المسجلة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddBranchDialog(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('إضافة فرع جديد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _branches.isEmpty
                ? const Center(child: Text('لا توجد فروع مسجلة حالياً.'))
                : Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(label: Text('معرف الفرع', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('اسم الفرع', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('الموقع / العنوان', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('حالة المزامنة', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _branches.map((b) {
                            final isSynced = b['is_synced'] == 1;
                            return DataRow(
                              cells: [
                                DataCell(Text(b['id'].toString())),
                                DataCell(Text(b['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(b['location']?.toString() ?? '—')),
                                DataCell(_buildSyncIndicator(isSynced)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('قائمة الموردين المعتمدين', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showAddSupplierDialog(),
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text('إضافة مورد جديد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _suppliers.isEmpty
                ? const Center(child: Text('لا يوجد موردين مسجلين حالياً.'))
                : Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(label: Text('اسم المورد', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('بيانات التواصل', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('الرصيد المالي', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('حالة المزامنة', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _suppliers.map((s) {
                            final isSynced = s['is_synced'] == 1;
                            final balance = (s['balance'] as num?)?.toDouble() ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text(s['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(s['phone']?.toString() ?? '—')),
                                DataCell(Text(s['contact_info']?.toString() ?? '—')),
                                DataCell(Text(s['email']?.toString() ?? '—')),
                                DataCell(Text('$balance ج.م')),
                                DataCell(_buildSyncIndicator(isSynced)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(bool isSynced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? LucideIcons.checkCircle2 : LucideIcons.cloudLightning,
            size: 12,
            color: isSynced ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 6),
          Text(
            isSynced ? 'متزامن' : 'أوفلاين معلق',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSynced ? Colors.green : Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBranchDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة فرع صيدلية جديد'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الفرع *'),
                    validator: (v) => v!.trim().isEmpty ? 'مطلوب إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locCtrl,
                    decoration: const InputDecoration(labelText: 'الموقع / العنوان'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addBranch(nameCtrl.text.trim(), locCtrl.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSupplierDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة مورد جديد للمستودع'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'اسم المورد *'),
                      validator: (v) => v!.trim().isEmpty ? 'مطلوب إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contactCtrl,
                      decoration: const InputDecoration(labelText: 'بيانات التواصل / الشخص المسؤول'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addrCtrl,
                      decoration: const InputDecoration(labelText: 'العنوان السكني / مقر المورد'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addSupplier(
                    nameCtrl.text.trim(),
                    contactCtrl.text.trim(),
                    addrCtrl.text.trim(),
                    phoneCtrl.text.trim(),
                    emailCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
