import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/injection_container.dart' as di;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Metrics
  double _totalSales = 0.0;
  double _totalReturns = 0.0;
  double _totalPurchases = 0.0;
  int _transactionCount = 0;

  List<Map<String, dynamic>> _salesInvoices = [];
  List<Map<String, dynamic>> _lowStock = [];
  List<Map<String, dynamic>> _expiring = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final startStr = _startDate.toIso8601String().split('T').first;
    final endStr = '${_endDate.toIso8601String().split('T').first} 23:59:59';

    // 1. Calculate sales in range
    final salesRes = await db.rawQuery('''
      SELECT COUNT(*) as count, SUM(total) as total 
      FROM sales_invoices 
      WHERE date >= ? AND date <= ?
    ''', [startStr, endStr]);
    
    final double salesTotal = (salesRes.first['total'] as num?)?.toDouble() ?? 0.0;
    final int salesCount = (salesRes.first['count'] as num?)?.toInt() ?? 0;

    // 2. Calculate returns in range
    final returnsRes = await db.rawQuery('''
      SELECT SUM(total) as total 
      FROM sales_returns 
      WHERE date >= ? AND date <= ?
    ''', [startStr, endStr]);

    final double returnsTotal = (returnsRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // 3. Calculate purchases in range
    final purchasesRes = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM purchase_invoices 
      WHERE invoice_date >= ? AND invoice_date <= ?
    ''', [startStr, endStr]);

    final double purchasesTotal = (purchasesRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // 4. Fetch list of sales invoices
    final List<Map<String, dynamic>> salesList = await db.rawQuery('''
      SELECT si.*, c.name as customer_name 
      FROM sales_invoices si
      LEFT JOIN customers c ON si.customer_id = c.id
      WHERE si.date >= ? AND si.date <= ?
      ORDER BY si.date DESC
    ''', [startStr, endStr]);

    // 5. Fetch low stock warnings (< 10)
    final List<Map<String, dynamic>> lowStockList = await db.rawQuery('''
      SELECT b.*, m.name as medicine_name 
      FROM batches b
      JOIN medicines m ON b.medicine_id = m.id
      WHERE b.quantity < 10
      LIMIT 20
    ''');

    // 6. Fetch expiring warnings (next 30 days)
    final thirtyDaysLater = DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T').first;
    final List<Map<String, dynamic>> expiringList = await db.rawQuery('''
      SELECT b.*, m.name as medicine_name 
      FROM batches b
      JOIN medicines m ON b.medicine_id = m.id
      WHERE b.expiry_date <= ?
      LIMIT 20
    ''', [thirtyDaysLater]);

    setState(() {
      _totalSales = salesTotal;
      _totalReturns = returnsTotal;
      _totalPurchases = purchasesTotal;
      _transactionCount = salesCount;
      _salesInvoices = salesList;
      _lowStock = lowStockList;
      _expiring = expiringList;
      _isLoading = false;
    });
  }

  void _setDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      if (preset == 'today') {
        _startDate = now;
        _endDate = now;
      } else if (preset == '7days') {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      } else if (preset == 'month') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      }
    });
    _loadReportData();
  }

  Future<void> _exportToCsv() async {
    final startStr = _startDate.toIso8601String().split('T').first;
    final endStr = _endDate.toIso8601String().split('T').first;

    // Build CSV Content
    final StringBuffer csv = StringBuffer();
    csv.writeln('\uFEFF'); // UTF-8 BOM for Excel Arabic encoding support
    csv.writeln('تقرير المبيعات والتقارير المالية والصيدلانية');
    csv.writeln('الفترة من:,$startStr,إلى:,$endStr');
    csv.writeln();
    csv.writeln('الملخص المالي');
    csv.writeln('المبيعات الإجمالية:,${_totalSales.toStringAsFixed(2)},ج.م');
    csv.writeln('مرتجع المبيعات الإجمالي:,${_totalReturns.toStringAsFixed(2)},ج.م');
    csv.writeln('صافي الإيرادات:,${(_totalSales - _totalReturns).toStringAsFixed(2)},ج.م');
    csv.writeln('إجمالي المشتريات:,${_totalPurchases.toStringAsFixed(2)},ج.م');
    csv.writeln('إجمالي المعاملات:,$_transactionCount');
    csv.writeln();
    csv.writeln('قائمة الفواتير للفترة المحددة');
    csv.writeln('رقم الفاتورة,التاريخ,العميل,طريقة الدفع,حالة الدفع,الإجمالي');
    for (var inv in _salesInvoices) {
      csv.writeln('${inv['id']},${inv['date'].split("T").first},${inv['customer_name'] ?? "زبون نقدي"},${inv['payment_method']},${inv['status']},${inv['total']}');
    }

    try {
      final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userHome != null) {
        final downloadsPath = p.join(userHome, 'Downloads');
        final fileName = 'sales_report_${startStr}_to_${endStr}.csv';
        final file = File(p.join(downloadsPath, fileName));
        await file.writeAsString(csv.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تصدير ملف Excel/CSV بنجاح وحفظه في مجلد التنزيلات: $downloadsPath'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تصدير التقرير: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _downloadPdfReport() async {
    final startStr = _startDate.toIso8601String().split('T').first;
    final endStr = _endDate.toIso8601String().split('T').first;

    try {
      final dio = di.sl<Dio>();
      final response = await dio.post(
        'http://127.0.0.1:8000/api/v1/reports/custom',
        data: {
          'start_date': startStr,
          'end_date': endStr,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userHome != null) {
        final downloadsPath = p.join(userHome, 'Downloads');
        final fileName = 'report_${startStr}_to_${endStr}.pdf';
        final file = File(p.join(downloadsPath, fileName));
        await file.writeAsBytes(response.data);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحميل ملف PDF بنجاح وحفظه في المجلد: $downloadsPath'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل تقرير PDF: تأكد من اتصالك بسيرفر المزامنة ($e)'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات المالية والصيدلانية'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.fileSpreadsheet),
            tooltip: 'تصدير كجدول Excel/CSV',
            onPressed: _exportToCsv,
          ),
          IconButton(
            icon: const Icon(LucideIcons.fileText),
            tooltip: 'حفظ وتحميل تقرير PDF',
            onPressed: _downloadPdfReport,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? theme.cardColor : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                        _loadReportData();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'تاريخ البداية', border: OutlineInputBorder()),
                      child: Text(_startDate.toIso8601String().split('T').first),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                        _loadReportData();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'تاريخ النهاية', border: OutlineInputBorder()),
                      child: Text(_endDate.toIso8601String().split('T').first),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Presets Buttons
                ElevatedButton(onPressed: () => _setDatePreset('today'), child: const Text('اليوم')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _setDatePreset('7days'), child: const Text('آخر 7 أيام')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _setDatePreset('month'), child: const Text('الشهر الحالي')),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Analytics Grid (Glassmorphism look)
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildAnalyticCard('إجمالي المبيعات', '${_totalSales.toStringAsFixed(2)} ج.م', LucideIcons.shoppingCart, Colors.teal),
                          _buildAnalyticCard('إجمالي المرتجعات', '${_totalReturns.toStringAsFixed(2)} ج.م', LucideIcons.cornerUpLeft, Colors.red),
                          _buildAnalyticCard('صافي الإيرادات', '${(_totalSales - _totalReturns).toStringAsFixed(2)} ج.m', LucideIcons.dollarSign, Colors.blue),
                          _buildAnalyticCard('إجمالي المشتريات', '${_totalPurchases.toStringAsFixed(2)} ج.م', LucideIcons.shoppingBag, Colors.purple),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Split tables: low stock & expiring warnings
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildWarningSection('تنبيهات المخزون (نواقص < 10)', _lowStock, Colors.red, LucideIcons.alertTriangle),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildWarningSection('تنبيهات الصلاحية (قرب الانتهاء < 30 يوم)', _expiring, Colors.orange, LucideIcons.clock),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sales Invoices List
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تفاصيل فواتير المبيعات في هذه الفترة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (_salesInvoices.isEmpty)
                                 const Padding(
                                   padding: EdgeInsets.all(32),
                                   child: Center(
                                     child: Text('لا توجد فواتير مبيعات في هذه الفترة الزمنية.'),
                                   ),
                                 )
                              else
                                Table(
                                  border: TableBorder.all(color: Colors.grey.withOpacity(0.2)),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1.5),
                                    2: FlexColumnWidth(3),
                                    3: FlexColumnWidth(1.5),
                                    4: FlexColumnWidth(1.5),
                                    5: FlexColumnWidth(2),
                                  },
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(color: Colors.black12),
                                      children: [
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('رقم الفاتورة', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('حالة الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                    ..._salesInvoices.map((inv) => TableRow(
                                          children: [
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text(inv['id'].toString().substring(0, inv['id'].toString().length > 10 ? 10 : inv['id'].toString().length) + '...')),
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text(inv['date'].split("T").first)),
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text(inv['customer_name'] ?? "زبون نقدي")),
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text(inv['payment_method'] ?? "نقدا")),
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text(inv['status'] ?? "مدفوع")),
                                            Padding(padding: const EdgeInsets.all(8.0), child: Text('${inv['total']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                        )),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(isDark ? 0.15 : 0.05),
              color.withOpacity(isDark ? 0.05 : 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? AppColors.slate300 : AppColors.slate500, fontSize: 13)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection(String title, List<Map<String, dynamic>> warnings, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            if (warnings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('لا توجد تنبيهات حالية.', style: TextStyle(color: Colors.grey))),
              )
            else
              Table(
                border: TableBorder.all(color: Colors.grey.withOpacity(0.2)),
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: color.withOpacity(0.05)),
                    children: const [
                      Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('المتاح/التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...warnings.map((warn) {
                    final displayVal = warn['quantity'] != null ? '${warn['quantity']} علبة' : warn['expiry_date'].toString();
                    return TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: Text(warn['medicine_name'] ?? 'دواء غير معروف')),
                        Padding(padding: const EdgeInsets.all(8.0), child: Text(displayVal, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
