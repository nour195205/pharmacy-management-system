import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/features/sales/domain/entities/sales_return.dart';
import 'package:desktop/features/sales/domain/entities/sales_return_item.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_event.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/injection_container.dart' as di;

class CreateSalesReturnPage extends StatefulWidget {
  const CreateSalesReturnPage({super.key});

  @override
  State<CreateSalesReturnPage> createState() => _CreateSalesReturnPageState();
}

class _CreateSalesReturnPageState extends State<CreateSalesReturnPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedInvoiceId;
  DateTime _returnDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();

  List<Map<String, dynamic>> _invoices = []; // List of original invoices
  List<_ReturnItemData> _invoiceItems = []; // Items in the selected invoice
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    // Fetch all sales invoices with customer name
    final List<Map<String, dynamic>> invoices = await db.rawQuery('''
      SELECT 
        si.*,
        c.name as customer_name
      FROM sales_invoices si
      LEFT JOIN customers c ON si.customer_id = c.id
      ORDER BY si.created_at DESC
    ''');

    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
  }

  Future<void> _loadInvoiceItems(String invoiceId) async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    // Fetch items in this invoice
    final List<Map<String, dynamic>> items = await db.rawQuery('''
      SELECT 
        sii.*,
        b.batch_number, b.selling_price, b.medicine_id,
        m.name as medicine_name
      FROM sales_invoice_items sii
      LEFT JOIN batches b ON sii.batch_id = b.id
      LEFT JOIN medicines m ON b.medicine_id = m.id
      WHERE sii.sales_invoice_id = ?
    ''', [invoiceId]);

    setState(() {
      _invoiceItems = items.map((map) {
        return _ReturnItemData(
          itemId: map['id'].toString(),
          batchId: map['batch_id'].toString(),
          batchNumber: map['batch_number']?.toString() ?? 'تشغيلة غير معروفة',
          medicineName: map['medicine_name']?.toString() ?? 'دواء غير معروف',
          soldQty: (map['qty'] as num).toInt(),
          sellingPrice: (map['price'] as num).toDouble(),
          returnQty: 0, // Starts at 0
        );
      }).toList();
    });
  }

  double get _totalReturnAmount {
    return _invoiceItems.fold(0.0, (sum, item) => sum + (item.returnQty * item.sellingPrice));
  }

  void _saveReturn() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفاتورة الأصلية أولاً')),
      );
      return;
    }

    final activeReturnItems = _invoiceItems.where((item) => item.returnQty > 0).toList();

    if (activeReturnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد منتج واحد على الأقل مع كمية مرجعة أكبر من صفر لإتمام العملية')),
      );
      return;
    }

    _formKey.currentState!.save();

    final originalInvoice = _invoices.firstWhere((inv) => inv['id'].toString() == _selectedInvoiceId);
    final customerName = originalInvoice['customer_name']?.toString();

    final salesReturn = SalesReturn(
      id: '',
      salesInvoiceId: _selectedInvoiceId!,
      date: _returnDate.toIso8601String().split('T').first,
      total: _totalReturnAmount,
      reason: _reasonController.text.isEmpty ? null : _reasonController.text,
      createdBy: 1,
      customerName: customerName,
      items: activeReturnItems.map((item) => SalesReturnItem(
        id: '',
        salesReturnId: '',
        batchId: item.batchId,
        batchNumber: item.batchNumber,
        medicineName: item.medicineName,
        quantity: item.returnQty,
        sellingPrice: item.sellingPrice,
        total: item.returnQty * item.sellingPrice,
      )).toList(),
    );

    context.read<SalesReturnsBloc>().add(AddSalesReturnEvent(salesReturn));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إجراء مرتجع مبيعات جديد'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Select Invoice Panel
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? theme.cardColor : Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'اختر فاتورة المبيعات الأصلية',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(LucideIcons.fileText),
                      ),
                      value: _selectedInvoiceId,
                      isExpanded: true,
                      items: _invoices.map((inv) {
                        final dateStr = inv['date']?.toString().split("T").first ?? '';
                        final clientStr = inv['customer_name'] != null ? 'العميل: ${inv['customer_name']}' : 'زبون كاش';
                        return DropdownMenuItem(
                          value: inv['id'].toString(),
                          child: Text('فاتورة بتاريخ: $dateStr | الإجمالي: ${inv['total']} ج.م | ($clientStr)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedInvoiceId = val;
                        });
                        if (val != null) {
                          _loadInvoiceItems(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDatePickerFormField(
                      fieldLabelText: 'تاريخ المرتجع',
                      initialDate: _returnDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateSaved: (date) {
                        _returnDate = date;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Reason Textfield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب إرجاع المنتجات',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            // Items List
            Expanded(
              child: _selectedInvoiceId == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.arrowUpCircle, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('الرجاء اختيار الفاتورة الأصلية من الأعلى لعرض الأدوية المباعة.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _invoiceItems.length,
                      itemBuilder: (context, index) {
                        final item = _invoiceItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                            child: Text('التشغيلة: ${item.batchNumber}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('سعر البيع الأصلي: ${item.sellingPrice} ج.م', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                          const SizedBox(width: 8),
                                          Text('الكمية المباعة: ${item.soldQty} علب', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.returnQty.toString(),
                                    decoration: const InputDecoration(labelText: 'الكمية المرجعة', isDense: true),
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val) ?? 0;
                                      if (parsed > item.soldQty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('خطأ: لا يمكن إرجاع كمية أكبر من المباعة في الفاتورة الأصيلة وهي (${item.soldQty} علبة)'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setState(() => item.returnQty = 0);
                                        return;
                                      }
                                      setState(() => item.returnQty = parsed);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text('المسترد: ${(item.returnQty * item.sellingPrice)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Return Summary Bottom Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي المبلغ المسترد: ${_totalReturnAmount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.cornerUpLeft),
                    label: const Text('تأكيد وإتمام المرتجع'),
                    onPressed: _saveReturn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}

class _ReturnItemData {
  String itemId;
  String batchId;
  String batchNumber;
  String medicineName;
  int soldQty;
  double sellingPrice;
  int returnQty;

  _ReturnItemData({
    required this.itemId,
    required this.batchId,
    required this.batchNumber,
    required this.medicineName,
    required this.soldQty,
    required this.sellingPrice,
    required this.returnQty,
  });
}
