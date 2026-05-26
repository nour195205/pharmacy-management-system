import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:desktop/features/inventory/domain/entities/batch.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_bloc.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_event.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_state.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_state.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BatchesBloc>().add(const LoadBatchesEvent());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<BatchesBloc>().add(SearchBatchesEvent(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون — التشغيلات'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              context.read<BatchesBloc>().add(const LoadBatchesEvent());
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Controls Row
            BlocBuilder<BatchesBloc, BatchesState>(
              builder: (context, state) {
                String? currentMedicineId;
                String? currentExpiryStatus;

                if (state is BatchesLoadedState) {
                  currentMedicineId = state.selectedMedicineId;
                  currentExpiryStatus = state.selectedExpiryStatus;
                }

                return Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'البحث عن طريق اسم الدواء أو رقم التشغيلة...',
                            prefixIcon: Icon(LucideIcons.search, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Expiry Status Filter
                    Container(
                      width: 170,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: currentExpiryStatus,
                          hint: const Text('حالة الصلاحية'),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('كل الحالات'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'expired',
                              child: Text('منتهية الصلاحية'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'expiring_soon',
                              child: Text('تنتهي قريباً (90 يوم)'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'valid',
                              child: Text('صالحة'),
                            ),
                          ],
                          onChanged: (status) {
                            context.read<BatchesBloc>().add(FilterBatchesEvent(
                              medicineId: currentMedicineId,
                              expiryStatus: status,
                            ));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add Button
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('إضافة تشغيلة جديدة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Main Data Table
            Expanded(
              child: BlocBuilder<BatchesBloc, BatchesState>(
                builder: (context, state) {
                  if (state is BatchesLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BatchesErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<BatchesBloc>().add(const LoadBatchesEvent());
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BatchesLoadedState) {
                    final list = state.filteredBatches;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.package,
                              size: 64,
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'لا توجد نتائج مطابقة لبحثك'
                                  : 'لا توجد تشغيلات مسجلة حالياً',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              ),
                              columns: const [
                                DataColumn(label: Text('اسم الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('رقم التشغيلة', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('تاريخ الإنتاج', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('تاريخ الانتهاء', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('سعر الشراء', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('سعر البيع', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                DataColumn(label: Text('حالة الصلاحية', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('المزامنة', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: list.map((batch) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        batch.medicineName ?? '—',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(Text(batch.batchNumber)),
                                    DataCell(Text(_formatDate(batch.manufactureDate))),
                                    DataCell(Text(_formatDate(batch.expiryDate))),
                                    DataCell(Text(_formatQuantity(batch.quantity))),
                                    DataCell(Text('${batch.purchasePrice} ج.م')),
                                    DataCell(Text('${batch.sellingPrice} ج.م')),
                                    DataCell(_buildExpiryBadge(batch.expiryDate)),
                                    DataCell(_buildSyncIndicator(batch.isSynced)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(LucideIcons.edit, size: 16, color: Colors.blue),
                                            tooltip: 'تعديل',
                                            onPressed: () => _showAddEditDialog(context, batch: batch),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash, size: 16, color: Colors.red),
                                            tooltip: 'حذف',
                                            onPressed: () => _confirmDelete(context, batch.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatQuantity(double qty) {
    if (qty == qty.toInt().toDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2);
  }

  Widget _buildExpiryBadge(String expiryDateStr) {
    final expiry = DateTime.tryParse(expiryDateStr);
    if (expiry == null) {
      return const Text('—');
    }

    final now = DateTime.now();
    final soon = now.add(const Duration(days: 90));

    String text;
    Color color;

    if (expiry.isBefore(now)) {
      text = 'منتهية';
      color = Colors.red;
    } else if (expiry.isBefore(soon)) {
      text = 'تنتهي قريباً';
      color = Colors.amber;
    } else {
      text = 'صالحة';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSyncIndicator(bool isSynced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.1),
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
            isSynced ? 'متزامن' : 'معلق',
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

  void _showAddEditDialog(BuildContext context, {Batch? batch}) {
    final formKey = GlobalKey<FormState>();
    final batchNumberCtrl = TextEditingController(text: batch?.batchNumber);
    final quantityCtrl = TextEditingController(text: batch?.quantity.toString());
    final purchasePriceCtrl = TextEditingController(text: batch?.purchasePrice.toString());
    final sellingPriceCtrl = TextEditingController(text: batch?.sellingPrice.toString());

    String? selectedMedicineId = batch?.medicineId;
    DateTime selectedManufactureDate = batch != null
        ? (DateTime.tryParse(batch.manufactureDate) ?? DateTime.now())
        : DateTime.now();
    DateTime selectedExpiryDate = batch != null
        ? (DateTime.tryParse(batch.expiryDate) ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 365));
    int selectedBranchId = batch?.branchId ?? 1;

    // Load medicines list from MedicinesBloc
    final medicinesState = context.read<MedicinesBloc>().state;
    List<Map<String, String>> medicineOptions = [];
    if (medicinesState is MedicinesLoadedState) {
      medicineOptions = medicinesState.medicines
          .map((m) => {'id': m.id, 'name': m.name})
          .toList();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(batch == null ? 'إضافة تشغيلة جديدة' : 'تعديل بيانات التشغيلة'),
              content: SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Medicine Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedMedicineId,
                          decoration: const InputDecoration(labelText: 'اسم الدواء *'),
                          items: medicineOptions.map((m) {
                            return DropdownMenuItem<String>(
                              value: m['id'],
                              child: Text(m['name']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedMedicineId = val;
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'يرجى اختيار الدواء' : null,
                        ),
                        const SizedBox(height: 16),

                        // Batch Number
                        TextFormField(
                          controller: batchNumberCtrl,
                          decoration: const InputDecoration(labelText: 'رقم التشغيلة *'),
                          validator: (v) => v!.trim().isEmpty ? 'يرجى إدخال رقم التشغيلة' : null,
                        ),
                        const SizedBox(height: 16),

                        // Manufacture & Expiry Dates
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'تاريخ الإنتاج *',
                                selectedDate: selectedManufactureDate,
                                onDateSelected: (date) {
                                  setState(() {
                                    selectedManufactureDate = date;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DatePickerField(
                                label: 'تاريخ الانتهاء *',
                                selectedDate: selectedExpiryDate,
                                onDateSelected: (date) {
                                  setState(() {
                                    selectedExpiryDate = date;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quantity
                        TextFormField(
                          controller: quantityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'الكمية *'),
                          validator: (v) {
                            if (v!.trim().isEmpty) return 'يرجى إدخال الكمية';
                            if (double.tryParse(v) == null) return 'يجب أن يكون رقماً';
                            if (double.parse(v) < 0) return 'الكمية يجب أن تكون 0 أو أكثر';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Purchase & Selling Prices
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchasePriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'سعر الشراء (ج.م) *'),
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'يرجى إدخال سعر الشراء';
                                  if (int.tryParse(v) == null) return 'يجب أن يكون رقماً صحيحاً';
                                  if (int.parse(v) < 0) return 'السعر يجب أن يكون 0 أو أكثر';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: sellingPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'سعر البيع (ج.م) *'),
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'يرجى إدخال سعر البيع';
                                  if (int.tryParse(v) == null) return 'يجب أن يكون رقماً صحيحاً';
                                  if (int.parse(v) < 0) return 'السعر يجب أن يكون 0 أو أكثر';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Branch ID
                        TextFormField(
                          initialValue: selectedBranchId.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'رقم الفرع *'),
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null) selectedBranchId = parsed;
                          },
                          validator: (v) {
                            if (v!.trim().isEmpty) return 'يرجى إدخال رقم الفرع';
                            if (int.tryParse(v) == null) return 'يجب أن يكون رقماً';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Validate expiry > manufacture
                      if (selectedExpiryDate.isBefore(selectedManufactureDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تاريخ الانتهاء يجب أن يكون بعد تاريخ الإنتاج'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final String id = batch?.id ?? const Uuid().v4();

                      // Resolve medicine name
                      String? medName = batch?.medicineName;
                      if (selectedMedicineId != null && medicineOptions.isNotEmpty) {
                        final found = medicineOptions.where((m) => m['id'] == selectedMedicineId);
                        if (found.isNotEmpty) {
                          medName = found.first['name'];
                        }
                      }

                      final newBatch = Batch(
                        id: id,
                        medicineId: selectedMedicineId!,
                        medicineName: medName,
                        batchNumber: batchNumberCtrl.text.trim(),
                        manufactureDate: selectedManufactureDate.toIso8601String().split('T').first,
                        expiryDate: selectedExpiryDate.toIso8601String().split('T').first,
                        quantity: double.parse(quantityCtrl.text),
                        purchasePrice: int.parse(purchasePriceCtrl.text),
                        sellingPrice: int.parse(sellingPriceCtrl.text),
                        branchId: selectedBranchId,
                        isSynced: false,
                      );

                      if (batch == null) {
                        this.context.read<BatchesBloc>().add(AddBatchEvent(newBatch));
                      } else {
                        this.context.read<BatchesBloc>().add(EditBatchEvent(newBatch));
                      }

                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذه التشغيلة؟ سيتم حذفها محلياً وجدولتها للحذف من الخادم.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<BatchesBloc>().add(DeleteBatchEvent(id));
                Navigator.pop(dialogCtx);
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Date Picker Field widget for batch form
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('ar'),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(LucideIcons.calendar, size: 18),
        ),
        child: Text(displayDate),
      ),
    );
  }
}
