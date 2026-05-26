import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice.dart';
import 'package:desktop/features/purchases/domain/entities/purchase_invoice_item.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_event.dart';
import 'package:desktop/services/database_service.dart';
import 'package:desktop/injection_container.dart' as di;

class CreatePurchaseInvoicePage extends StatefulWidget {
  const CreatePurchaseInvoicePage({super.key});

  @override
  State<CreatePurchaseInvoicePage> createState() => _CreatePurchaseInvoicePageState();
}

class _CreatePurchaseInvoicePageState extends State<CreatePurchaseInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSupplierId;
  final String _selectedBranchId = "1"; // Default branch ID
  DateTime _invoiceDate = DateTime.now();
  
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _medicines = [];
  
  final List<_InvoiceItemData> _invoiceItems = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final dbService = di.sl<DatabaseService>();
    final db = await dbService.database;

    final suppliers = await db.query('suppliers');
    final medicines = await db.query('medicines');

    setState(() {
      _suppliers = suppliers;
      _medicines = medicines;
      if (_suppliers.isNotEmpty) {
        _selectedSupplierId = _suppliers.first['id'].toString();
      }
      _isLoading = false;
    });
  }

  void _addMedicine(Map<String, dynamic> medicine) {
    setState(() {
      // Check if already exists
      final existingIndex = _invoiceItems.indexWhere((item) => item.medicineId == medicine['id'].toString());
      if (existingIndex >= 0) {
        _invoiceItems[existingIndex].quantity += 1;
      } else {
        _invoiceItems.add(_InvoiceItemData(
          medicineId: medicine['id'].toString(),
          medicineName: medicine['name'].toString(),
          quantity: 1,
          purchasePrice: 0.0,
          sellingPrice: (medicine['price'] as num?)?.toDouble() ?? 0.0,
          manufactureDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ));
      }
    });
  }

  double get _totalAmount {
    return _invoiceItems.fold(0.0, (sum, item) => sum + (item.quantity * item.purchasePrice));
  }

  void _saveInvoice() {
    if (!_formKey.currentState!.validate()) return;
    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة دواء واحد على الأقل للفاتورة')),
      );
      return;
    }

    _formKey.currentState!.save();

    final supplierName = _suppliers.firstWhere((s) => s['id'].toString() == _selectedSupplierId)['name'].toString();

    final invoice = PurchaseInvoice(
      id: '',
      branchId: int.parse(_selectedBranchId),
      supplierId: _selectedSupplierId!,
      supplierName: supplierName,
      userId: 1, // Current logged in user ID
      invoiceDate: _invoiceDate.toIso8601String().split('T').first,
      totalAmount: _totalAmount,
      items: _invoiceItems.map((item) => PurchaseInvoiceItem(
        medicineId: item.medicineId,
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        sellingPrice: item.sellingPrice,
        manufactureDate: item.manufactureDate.toIso8601String().split('T').first,
        expiryDate: item.expiryDate.toIso8601String().split('T').first,
      )).toList(),
    );

    context.read<PurchaseInvoicesBloc>().add(AddPurchaseInvoiceEvent(invoice));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة فاتورة مشتريات جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top Section: Invoice Meta Data
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'المورد', border: OutlineInputBorder()),
                      value: _selectedSupplierId,
                      items: _suppliers.map((s) => DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(s['name'].toString()),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedSupplierId = val),
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDatePickerFormField(
                      fieldLabelText: 'تاريخ الفاتورة',
                      initialDate: _invoiceDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateSaved: (date) {
                        _invoiceDate = date;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return _medicines.where((medicine) {
                    final nameMatch = medicine['name'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase());
                    final barcodeMatch = medicine['barcode']?.toString().contains(textEditingValue.text) ?? false;
                    return nameMatch || barcodeMatch;
                  });
                },
                displayStringForOption: (option) => option['name'],
                onSelected: (option) {
                  _addMedicine(option);
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'ابحث عن دواء لإضافته (بالاسم أو الباركود)',
                      prefixIcon: const Icon(LucideIcons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                    ),
                  );
                },
              ),
            ),

            // Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _invoiceItems.length,
                itemBuilder: (context, index) {
                  final item = _invoiceItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.red),
                                onPressed: () => setState(() => _invoiceItems.removeAt(index)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  decoration: const InputDecoration(labelText: 'الكمية', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() => item.quantity = int.tryParse(val) ?? 0);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.purchasePrice.toString(),
                                  decoration: const InputDecoration(labelText: 'سعر الشراء', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() => item.purchasePrice = double.tryParse(val) ?? 0);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.sellingPrice.toString(),
                                  decoration: const InputDecoration(labelText: 'سعر البيع', isDense: true),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    item.sellingPrice = double.tryParse(val) ?? 0;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: item.manufactureDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() => item.manufactureDate = date);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(labelText: 'تاريخ الإنتاج', isDense: true),
                                    child: Text(item.manufactureDate.toIso8601String().split('T').first),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: item.expiryDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() => item.expiryDate = date);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(labelText: 'تاريخ الانتهاء', isDense: true),
                                    child: Text(item.expiryDate.toIso8601String().split('T').first),
                                  ),
                                ),
                              ),
                            ],
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
                color: theme.cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الإجمالي: \${_totalAmount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.save),
                    label: const Text('حفظ الفاتورة'),
                    onPressed: _saveInvoice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.green,
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

class _InvoiceItemData {
  String medicineId;
  String medicineName;
  int quantity;
  double purchasePrice;
  double sellingPrice;
  DateTime manufactureDate;
  DateTime expiryDate;

  _InvoiceItemData({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.manufactureDate,
    required this.expiryDate,
  });
}
