import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:desktop/features/medicines/domain/entities/medicine.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_event.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_state.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch fetch event on widget render
    context.read<MedicinesBloc>().add(const LoadMedicinesEvent());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<MedicinesBloc>().add(SearchMedicinesEvent(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة مستودع الأدوية'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              context.read<MedicinesBloc>().add(const LoadMedicinesEvent());
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
            // Header Stats & Search Controls Row
            Row(
              children: [
                Expanded(
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
                        hintText: 'البحث عن طريق اسم الدواء، الباركود، أو التصنيف...',
                        prefixIcon: Icon(LucideIcons.search, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('إضافة دواء جديد'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Data Area
            Expanded(
              child: BlocBuilder<MedicinesBloc, MedicinesState>(
                builder: (context, state) {
                  if (state is MedicinesLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } 
                  
                  if (state is MedicinesErrorState) {
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
                              context.read<MedicinesBloc>().add(const LoadMedicinesEvent());
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MedicinesLoadedState) {
                    final list = state.filteredMedicines;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.pill,
                              size: 64,
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty 
                                  ? 'لا توجد نتائج مطابقة لبحثك' 
                                  : 'مستودع الأدوية فارغ حالياً',
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
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            ),
                            columns: const [
                              DataColumn(label: Text('اسم الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الباركود', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('سعر البيع', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الوحدة', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('حالة المزامنة', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: list.map((medicine) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      medicine.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  DataCell(Text(medicine.barcode ?? '—')),
                                  DataCell(Text(medicine.category)),
                                  DataCell(Text('${medicine.price} ج.م')),
                                  DataCell(Text(medicine.unit)),
                                  DataCell(_buildSyncIndicator(medicine.isSynced)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.edit, size: 16, color: Colors.blue),
                                          tooltip: 'تعديل',
                                          onPressed: () => _showAddEditDialog(context, medicine: medicine),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash, size: 16, color: Colors.red),
                                          tooltip: 'حذف',
                                          onPressed: () => _confirmDelete(context, medicine.id),
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

  void _showAddEditDialog(BuildContext context, {Medicine? medicine}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: medicine?.name);
    final categoryCtrl = TextEditingController(text: medicine?.category ?? 'عام');
    final descCtrl = TextEditingController(text: medicine?.description);
    final barcodeCtrl = TextEditingController(text: medicine?.barcode);
    final priceCtrl = TextEditingController(text: medicine?.price.toString());
    final reorderCtrl = TextEditingController(text: medicine?.reorderLevel ?? '10');
    
    String selectedUnit = medicine?.unit ?? 'علبه';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(medicine == null ? 'إضافة دواء جديد' : 'تعديل بيانات الدواء'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Medicine Name
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'اسم الدواء *'),
                          validator: (v) => v!.trim().isEmpty ? 'يرجى إدخال اسم الدواء' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Category & Barcode
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: categoryCtrl,
                                decoration: const InputDecoration(labelText: 'التصنيف *'),
                                validator: (v) => v!.trim().isEmpty ? 'يرجى إدخال تصنيف' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: barcodeCtrl,
                                decoration: const InputDecoration(labelText: 'الباركود'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Price & Unit
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'سعر البيع (ج.م) *'),
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'يرجى إدخال السعر';
                                  if (int.tryParse(v) == null) return 'يجب أن يكون رقماً صحيحاً';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: const InputDecoration(labelText: 'وحدة البيع *'),
                                items: const [
                                  DropdownMenuItem(value: 'شريط', child: Text('شريط')),
                                  DropdownMenuItem(value: 'علبه', child: Text('علبه')),
                                  DropdownMenuItem(value: 'زجاجه', child: Text('زجاجه')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedUnit = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Reorder Level
                        TextFormField(
                          controller: reorderCtrl,
                          decoration: const InputDecoration(labelText: 'حد إعادة الطلب (أدنى كمية في المخزن)'),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'الوصف أو الملاحظات'),
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
                      final parsedPrice = int.parse(priceCtrl.text);
                      final String id = medicine?.id ?? const Uuid().v4();

                      final newMedicine = Medicine(
                        id: id,
                        name: nameCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                        barcode: barcodeCtrl.text.trim().isEmpty ? null : barcodeCtrl.text.trim(),
                        unit: selectedUnit,
                        price: parsedPrice,
                        reorderLevel: reorderCtrl.text.trim().isEmpty ? '10' : reorderCtrl.text.trim(),
                        isActive: medicine?.isActive ?? true,
                        isSynced: false,
                      );

                      if (medicine == null) {
                        context.read<MedicinesBloc>().add(AddMedicineEvent(newMedicine));
                      } else {
                        context.read<MedicinesBloc>().add(EditMedicineEvent(newMedicine));
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
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا الدواء؟ سيتم حذفه محلياً وجدولته للحذف من الخادم.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<MedicinesBloc>().add(DeleteMedicineEvent(id));
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
