import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_return_item.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_event.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/injection_container.dart' as di;

class CreatePurchaseReturnPage extends StatefulWidget {
  const CreatePurchaseReturnPage({super.key});

  @override
  State<CreatePurchaseReturnPage> createState() => _CreatePurchaseReturnPageState();
}

class _CreatePurchaseReturnPageState extends State<CreatePurchaseReturnPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedInvoiceId;
  DateTime _returnDate = DateTime.now();
  String _reason = '';
  
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _invoiceItems = [];
  
  final Map<String, int> _returnQuantities = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final invoices = await db.rawQuery('''
      SELECT pi.*, s.name as supplier_name 
      FROM purchase_invoices pi 
      LEFT JOIN suppliers s ON pi.supplier_id = s.id
      ORDER BY pi.created_at DESC
    ''');

    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
  }

  Future<void> _loadInvoiceItems(String invoiceId) async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final items = await db.rawQuery('''
      SELECT 
        pii.*, 
        b.batch_number, b.medicine_id,
        m.name as medicine_name
      FROM purchase_invoice_items pii
      LEFT JOIN batches b ON pii.batch_id = b.id
      LEFT JOIN medicines m ON b.medicine_id = m.id
      WHERE pii.purchase_invoice_id = ?
    ''', [invoiceId]);

    setState(() {
      _invoiceItems = items;
      _returnQuantities.clear();
      for (var item in items) {
        _returnQuantities[item['batch_id'].toString()] = 0; // default 0 return quantity
      }
    });
  }

  double get _totalReturnAmount {
    double total = 0;
    for (var item in _invoiceItems) {
      final batchId = item['batch_id'].toString();
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final retQty = _returnQuantities[batchId] ?? 0;
      total += retQty * price;
    }
    return total;
  }

  void _saveReturn() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvoiceId == null) return;
    
    _formKey.currentState!.save();

    final List<PurchaseReturnItem> returnItems = [];
    for (var item in _invoiceItems) {
      final batchId = item['batch_id'].toString();
      final retQty = _returnQuantities[batchId] ?? 0;
      if (retQty > 0) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        returnItems.add(PurchaseReturnItem(
          batchId: batchId,
          quantity: retQty,
          purchasePrice: price,
          total: retQty * price,
        ));
      }
    }

    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال كمية مرتجعة واحدة على الأقل')),
      );
      return;
    }

    final invoice = _invoices.firstWhere((inv) => inv['id'].toString() == _selectedInvoiceId);

    final purchaseReturn = PurchaseReturn(
      id: '',
      purchaseInvoiceId: _selectedInvoiceId!,
      supplierName: invoice['supplier_name']?.toString(),
      userId: 1,
      date: _returnDate.toIso8601String().split('T').first,
      total: _totalReturnAmount,
      reason: _reason,
      createdBy: 1,
      items: returnItems,
    );

    context.read<PurchaseReturnsBloc>().add(AddPurchaseReturnEvent(purchaseReturn));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة مرتجع مشتريات'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'اختر فاتورة الشراء الأصلية', border: OutlineInputBorder()),
                          value: _selectedInvoiceId,
                          items: _invoices.map((inv) => DropdownMenuItem(
                            value: inv['id'].toString(),
                            child: Text("فاتورة بتاريخ \${inv['invoice_date']} - مورد: \${inv['supplier_name']} - قيمة: \${inv['total_amount']}"),
                          )).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedInvoiceId = val;
                              if (val != null) _loadInvoiceItems(val);
                            });
                          },
                          validator: (val) => val == null ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InputDatePickerFormField(
                          fieldLabelText: 'تاريخ الإرجاع',
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
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'سبب الإرجاع', border: OutlineInputBorder()),
                    onSaved: (val) => _reason = val ?? '',
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: _selectedInvoiceId == null 
                ? const Center(child: Text('الرجاء اختيار الفاتورة لعرض بنودها'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _invoiceItems.length,
                    itemBuilder: (context, index) {
                      final item = _invoiceItems[index];
                      final maxQty = (item['qty'] as num?)?.toInt() ?? 0;
                      final batchId = item['batch_id'].toString();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['medicine_name']?.toString() ?? 'غير معروف', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text("رقم التشغيلة: \${item['batch_number']} | الكمية المشتراة: $maxQty | السعر: \${item['price']}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: 'الكمية المرتجعة', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  initialValue: '0',
                                  validator: (val) {
                                    final v = int.tryParse(val ?? '0') ?? 0;
                                    if (v < 0 || v > maxQty) return 'خطأ في الكمية';
                                    return null;
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      _returnQuantities[batchId] = int.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي المرتجع: \${_totalReturnAmount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.save),
                    label: const Text('تأكيد الإرجاع'),
                    onPressed: _saveReturn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
