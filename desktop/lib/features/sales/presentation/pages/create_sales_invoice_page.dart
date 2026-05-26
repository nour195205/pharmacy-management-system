import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice.dart';
import 'package:desktop/features/sales/domain/entities/sales_invoice_item.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_event.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/injection_container.dart' as di;

class CreateSalesInvoicePage extends StatefulWidget {
  const CreateSalesInvoicePage({super.key});

  @override
  State<CreateSalesInvoicePage> createState() => _CreateSalesInvoicePageState();
}

class _CreateSalesInvoicePageState extends State<CreateSalesInvoicePage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  final String _selectedBranchId = "1";
  DateTime _invoiceDate = DateTime.now();
  String _paymentMethod = 'نقدا'; // 'نقدا', 'بطاقة', 'أخرى'
  String _status = 'مدفوع'; // 'مدفوع', 'معلق', 'ملغى'
  final TextEditingController _noteController = TextEditingController();

  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _availableBatches = []; // Batches with qty > 0
  final List<_SalesItemData> _salesItems = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final customers = await db.query('customers');

    // Query batches with quantity > 0 and join with medicines to get names and details
    final List<Map<String, dynamic>> batches = await db.rawQuery('''
      SELECT 
        b.*,
        m.name as medicine_name,
        m.price as medicine_price,
        m.unit as medicine_unit
      FROM batches b
      JOIN medicines m ON b.medicine_id = m.id
      WHERE b.quantity > 0
      ORDER BY b.expiry_date ASC
    ''');

    setState(() {
      _customers = customers;
      _availableBatches = batches;
      _isLoading = false;
    });
  }

  void _addBatchToSale(Map<String, dynamic> batch) {
    setState(() {
      final batchId = batch['id'].toString();
      final existingIndex = _salesItems.indexWhere((item) => item.batchId == batchId);

      final double maxQty = (batch['quantity'] as num).toDouble();
      final int price = (batch['selling_price'] as num).toInt();

      if (existingIndex >= 0) {
        if (_salesItems[existingIndex].quantity + 1 > maxQty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('عذراً، الكمية المطلوبة تتجاوز المتاح في هذه التشغيلة (${maxQty.toInt()} علبة/شريط)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _salesItems[existingIndex].quantity += 1;
      } else {
        _salesItems.add(_SalesItemData(
          batchId: batchId,
          batchNumber: batch['batch_number'].toString(),
          medicineId: batch['medicine_id'].toString(),
          medicineName: batch['medicine_name'].toString(),
          expiryDate: batch['expiry_date'].toString(),
          quantity: 1,
          price: price,
          maxQuantity: maxQty,
        ));
      }
    });
  }

  double get _totalAmount {
    return _salesItems.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
  }

  void _saveInvoice() {
    if (!_formKey.currentState!.validate()) return;
    if (_salesItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة منتج واحد على الأقل لإجراء البيع')),
      );
      return;
    }

    _formKey.currentState!.save();

    String? customerName;
    if (_selectedCustomerId != null) {
      final customer = _customers.firstWhere((c) => c['id'].toString() == _selectedCustomerId);
      customerName = customer['name'].toString();
    }

    final invoice = SalesInvoice(
      id: '',
      branchId: int.parse(_selectedBranchId),
      customerId: _selectedCustomerId,
      customerName: customerName,
      date: _invoiceDate.toIso8601String().split('T').first,
      total: _totalAmount,
      status: _status,
      paymentMethod: _paymentMethod,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdBy: 1,
      items: _salesItems.map((item) => SalesInvoiceItem(
        id: '',
        salesInvoiceId: '',
        batchId: item.batchId,
        batchNumber: item.batchNumber,
        medicineName: item.medicineName,
        quantity: item.quantity,
        price: item.price,
      )).toList(),
    );

    context.read<SalesInvoicesBloc>().add(AddSalesInvoiceEvent(invoice));
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
        title: const Text('شاشة نقطة البيع الفورية (POS Cashier)'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Meta Panel (Customer & Payment Options)
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? theme.cardColor : Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'العميل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      value: _selectedCustomerId,
                      hint: const Text('زبون نقدي (كاش)'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('زبون نقدي (كاش)'),
                        ),
                        ..._customers.map((c) => DropdownMenuItem(
                          value: c['id'].toString(),
                          child: Text('${c['name']} (${c['phone'] ?? "بدون رقم"})'),
                        )),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCustomerId = val;
                          // If cash customer, status should be paid
                          if (val == null) {
                            _status = 'مدفوع';
                            _paymentMethod = 'نقدا';
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'طريقة الدفع', border: OutlineInputBorder()),
                      value: _paymentMethod,
                      items: const [
                        DropdownMenuItem(value: 'نقدا', child: Text('نقداً (Cash)')),
                        DropdownMenuItem(value: 'بطاقة', child: Text('شبكة / بطاقة')),
                        DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                      ],
                      onChanged: (val) => setState(() => _paymentMethod = val ?? 'نقدا'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'حالة الدفع', border: OutlineInputBorder()),
                      value: _status,
                      items: [
                        const DropdownMenuItem(value: 'مدفوع', child: Text('مدفوع')),
                        // Only allow pending (on-credit) if a customer is selected
                        if (_selectedCustomerId != null)
                          const DropdownMenuItem(value: 'معلق', child: Text('معلق (شُكك / ذمم)')),
                      ],
                      onChanged: (val) => setState(() => _status = val ?? 'مدفوع'),
                    ),
                  ),
                ],
              ),
            ),

            // Note Textfield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات الفاتورة (اختياري)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            // Autocomplete Search for Available Stock Batches
            Padding(
              padding: const EdgeInsets.all(16),
              child: Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return _availableBatches.where((batch) {
                    final nameMatch = batch['medicine_name'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase());
                    final numberMatch = batch['batch_number'].toString().contains(textEditingValue.text);
                    return nameMatch || numberMatch;
                  });
                },
                displayStringForOption: (option) => '${option['medicine_name']} (صلاحية: ${option['expiry_date']}) - سعر: ${option['selling_price']} ج.م',
                onSelected: (option) {
                  _addBatchToSale(option);
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'ابحث عن دواء للبيع (الاسم، الباركود أو رقم التشغيلة المتوفرة)',
                      prefixIcon: const Icon(LucideIcons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                    ),
                  );
                },
              ),
            ),

            // Sales Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _salesItems.length,
                itemBuilder: (context, index) {
                  final item = _salesItems[index];
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text('انتهاء: ${item.expiryDate}', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('المتاح: ${item.maxQuantity.toInt()} علبة', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              decoration: const InputDecoration(labelText: 'الكمية المباعة', isDense: true),
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                final parsed = int.tryParse(val) ?? 0;
                                if (parsed > item.maxQuantity) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('عذراً، لا تتوفر هذه الكمية. الكمية القصوى المتوفرة هي ${item.maxQuantity.toInt()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setState(() => item.quantity = item.maxQuantity.toInt());
                                  return;
                                }
                                setState(() => item.quantity = parsed);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('${item.price} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 16),
                          Text('الإجمالي: ${(item.quantity * item.price)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.red),
                            onPressed: () => setState(() => _salesItems.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Invoice Summary Bottom Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي الفاتورة: ${_totalAmount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.save),
                    label: const Text('تأكيد البيع وطباعة الفاتورة'),
                    onPressed: _saveInvoice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.teal,
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

class _SalesItemData {
  String batchId;
  String batchNumber;
  String medicineId;
  String medicineName;
  String expiryDate;
  int quantity;
  int price;
  double maxQuantity;

  _SalesItemData({
    required this.batchId,
    required this.batchNumber,
    required this.medicineId,
    required this.medicineName,
    required this.expiryDate,
    required this.quantity,
    required this.price,
    required this.maxQuantity,
  });
}
