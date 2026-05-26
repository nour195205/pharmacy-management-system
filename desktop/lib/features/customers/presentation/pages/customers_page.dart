import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:desktop/features/customers/domain/entities/customer.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_event.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_state.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(const LoadCustomersEvent());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CustomersBloc>().add(SearchCustomersEvent(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء والحسابات الائتمانية'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              context.read<CustomersBloc>().add(const LoadCustomersEvent());
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
            // Controls row
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
                        hintText: 'البحث عن طريق اسم العميل، رقم الهاتف، أو العنوان...',
                        prefixIcon: Icon(LucideIcons.search, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context),
                  icon: const Icon(LucideIcons.userPlus, size: 18),
                  label: const Text('إضافة عميل جديد'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customers data view area
            Expanded(
              child: BlocBuilder<CustomersBloc, CustomersState>(
                builder: (context, state) {
                  if (state is CustomersLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomersErrorState) {
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
                              context.read<CustomersBloc>().add(const LoadCustomersEvent());
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CustomersLoadedState) {
                    final list = state.filteredCustomers;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 64,
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'لا توجد نتائج مطابقة لبحثك'
                                  : 'لا يوجد عملاء مسجلين حالياً',
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
                              DataColumn(label: Text('اسم العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('العنوان', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('حد الائتمان المسموح', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('حالة المزامنة', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: list.map((customer) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      customer.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  DataCell(Text(customer.phone ?? '—')),
                                  DataCell(Text(customer.address ?? '—')),
                                  DataCell(Text('${customer.creditLimit.toStringAsFixed(2)} ج.م')),
                                  DataCell(_buildSyncIndicator(customer.isSynced)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.edit, size: 16, color: Colors.blue),
                                          tooltip: 'تعديل البيانات',
                                          onPressed: () => _showAddEditDialog(context, customer: customer),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash, size: 16, color: Colors.red),
                                          tooltip: 'حذف العميل',
                                          onPressed: () => _confirmDelete(context, customer.id),
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

  void _showAddEditDialog(BuildContext context, {Customer? customer}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: customer?.name);
    final phoneCtrl = TextEditingController(text: customer?.phone);
    final addrCtrl = TextEditingController(text: customer?.address);
    final creditCtrl = TextEditingController(text: customer?.creditLimit.toString() ?? '0.0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(customer == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'اسم العميل *'),
                      validator: (v) => v!.trim().isEmpty ? 'يرجى إدخال اسم العميل' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: creditCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'حد الائتمان المسموح به (ج.م) *'),
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'يرجى إدخال حد الائتمان';
                        if (double.tryParse(v) == null) return 'يجب أن يكون قيمة عشرية صحيحة';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addrCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'العنوان السكني للعميل'),
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
                  final parsedCredit = double.parse(creditCtrl.text);
                  final String id = customer?.id ?? const Uuid().v4();

                  final newCustomer = Customer(
                    id: id,
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                    address: addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim(),
                    creditLimit: parsedCredit,
                    isSynced: false,
                  );

                  if (customer == null) {
                    context.read<CustomersBloc>().add(AddCustomerEvent(newCustomer));
                  } else {
                    context.read<CustomersBloc>().add(EditCustomerEvent(newCustomer));
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
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من رغبتك في حذف هذا العميل؟ سيتم حذفه محلياً وجدولته للحذف من الخادم.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<CustomersBloc>().add(DeleteCustomerEvent(id));
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
