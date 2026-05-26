import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_state.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_state.dart';
import 'package:desktop/features/sales/presentation/pages/create_sales_invoice_page.dart';
import 'package:desktop/features/sales/presentation/pages/create_sales_return_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter State
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPaymentMethod;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh when tab changes to show/hide status filters
    });
    _refreshData();
  }

  void _refreshData() {
    context.read<SalesInvoicesBloc>().add(const LoadSalesInvoicesEvent());
    context.read<SalesReturnsBloc>().add(const LoadSalesReturnsEvent());
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _filterStatus = null;
      _filterPaymentMethod = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDeleteInvoice(BuildContext context, String invoiceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(LucideIcons.alertTriangle, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد حذف الفاتورة', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف فاتورة المبيعات هذه نهائياً؟\nسيتم إعادة كميات المنتجات المباعة في الفاتورة إلى المخزن تلقائياً.',
          style: TextStyle(fontSize: 14, height: 1.5, fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SalesInvoicesBloc>().add(DeleteSalesInvoiceEvent(invoiceId));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام المبيعات ونقطة البيع (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.slate600,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'فواتير المبيعات', icon: Icon(LucideIcons.shoppingCart)),
            Tab(text: 'مرتجع المبيعات', icon: Icon(LucideIcons.cornerUpLeft)),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SalesInvoicesBloc, SalesInvoicesState>(
            listener: (context, state) {
              if (state is SalesInvoiceOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is SalesInvoicesErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.xCircle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<SalesReturnsBloc, SalesReturnsState>(
            listener: (context, state) {
              if (state is SalesReturnOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.checkCircle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is SalesReturnsErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.xCircle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Column(
          children: [
            _buildFilterPanel(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInvoicesTab(context),
                  _buildReturnsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_tabController.index == 0) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSalesInvoicePage()));
            _refreshData();
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSalesReturnPage()));
            _refreshData();
          }
        },
        icon: const Icon(LucideIcons.plus),
        label: Text(_tabController.index == 0 ? 'شاشة بيع جديدة (POS)' : 'مرتجع مبيعات جديد', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search & Reset
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    labelText: 'البحث باسم العميل أو كود الفاتورة...',
                    prefixIcon: const Icon(LucideIcons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('إعادة تعيين', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Dropdowns & Dates
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Show Invoice filters only on first tab
                if (_tabController.index == 0) ...[
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      value: _filterStatus,
                      decoration: InputDecoration(
                        labelText: 'حالة الدفع',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('الكل')),
                        DropdownMenuItem(value: 'مدفوع', child: Text('مدفوع')),
                        DropdownMenuItem(value: 'معلق', child: Text('معلق (ذمم)')),
                      ],
                      onChanged: (val) => setState(() => _filterStatus = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      value: _filterPaymentMethod,
                      decoration: InputDecoration(
                        labelText: 'طريقة الدفع',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('الكل')),
                        DropdownMenuItem(value: 'نقدا', child: Text('نقداً')),
                        DropdownMenuItem(value: 'بطاقة', child: Text('بطاقة')),
                      ],
                      onChanged: (val) => setState(() => _filterPaymentMethod = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Date pickers
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                  icon: const Icon(LucideIcons.calendar, size: 14),
                  label: Text(
                    _startDate == null
                        ? 'من تاريخ'
                        : 'من: ${_startDate!.year}-${_startDate!.month}-${_startDate!.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                  icon: const Icon(LucideIcons.calendar, size: 14),
                  label: Text(
                    _endDate == null
                        ? 'إلى تاريخ'
                        : 'إلى: ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<SalesInvoicesBloc, SalesInvoicesState>(
      builder: (context, state) {
        if (state is SalesInvoicesLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesInvoicesErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل فواتير المبيعات:\n${state.message}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<SalesInvoicesBloc>().add(const LoadSalesInvoicesEvent()),
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        } else if (state is SalesInvoicesLoadedState) {
          // Client-side filtering
          final filteredInvoices = state.invoices.where((invoice) {
            final clientName = invoice.customerName?.toLowerCase() ?? 'زبون نقدي كاش';
            final invoiceId = invoice.id.toLowerCase();
            final matchesQuery = clientName.contains(_searchQuery.toLowerCase()) ||
                invoiceId.contains(_searchQuery.toLowerCase());

            final matchesStatus = _filterStatus == null || invoice.status == _filterStatus;
            final matchesMethod = _filterPaymentMethod == null || invoice.paymentMethod == _filterPaymentMethod;

            bool matchesDate = true;
            final invDate = DateTime.tryParse(invoice.date);
            if (invDate != null) {
              if (_startDate != null) {
                final startComp = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
                if (invDate.isBefore(startComp)) matchesDate = false;
              }
              if (_endDate != null) {
                final endComp = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
                if (invDate.isAfter(endComp)) matchesDate = false;
              }
            }

            return matchesQuery && matchesStatus && matchesMethod && matchesDate;
          }).toList();

          if (filteredInvoices.isEmpty) {
            return _buildEmptyState(
              icon: LucideIcons.shoppingBag,
              message: 'لا توجد فواتير مبيعات مطابقة للفلاتر الحالية.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredInvoices.length,
            itemBuilder: (context, index) {
              final invoice = filteredInvoices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: const Icon(LucideIcons.fileText, color: Colors.teal),
                  ),
                  title: Row(
                    children: [
                      Text(
                        'العميل: ${invoice.customerName ?? "زبون نقدي كاش"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(invoice.status),
                    ],
                  ),
                  subtitle: Text(
                    'التاريخ: ${invoice.date.split("T").first} | الدفع: ${invoice.paymentMethod} | الإجمالي: ${invoice.total.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        invoice.isSynced ? LucideIcons.cloudLightning : LucideIcons.cloudOff,
                        color: invoice.isSynced ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronDown),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: isDark ? AppColors.slate800 : AppColors.slate50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (invoice.note != null && invoice.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.info, size: 16, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ملاحظات الفاتورة: ${invoice.note}',
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          const Text(
                            'محتويات الفاتورة:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Table(
                            border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.black12),
                                children: [
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                              ),
                              ...invoice.items.map((item) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? 'دواء غير معروف', style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString(), style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text('${item.price} ج.م', style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text('${item.total} ج.م', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal))),
                                ],
                              )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Premium POS actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateSalesInvoicePage(invoiceToEdit: invoice),
                                    ),
                                  );
                                  _refreshData();
                                },
                                icon: const Icon(LucideIcons.edit2, size: 14),
                                label: const Text('تعديل الفاتورة (POS)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _confirmDeleteInvoice(context, invoice.id),
                                icon: const Icon(LucideIcons.trash2, size: 14),
                                label: const Text('حذف واسترجاع الكميات'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: Text('جاري التحميل...'));
      },
    );
  }

  Widget _buildReturnsTab(BuildContext context) {
    return BlocBuilder<SalesReturnsBloc, SalesReturnsState>(
      builder: (context, state) {
        if (state is SalesReturnsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesReturnsErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل مرتجعات المبيعات:\n${state.message}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<SalesReturnsBloc>().add(const LoadSalesReturnsEvent()),
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        } else if (state is SalesReturnsLoadedState) {
          final filteredReturns = state.returns.where((ret) {
            final clientName = ret.customerName?.toLowerCase() ?? 'زبون نقدي كاش';
            final invoiceId = ret.salesInvoiceId.toLowerCase();
            final matchesQuery = clientName.contains(_searchQuery.toLowerCase()) ||
                invoiceId.contains(_searchQuery.toLowerCase());

            bool matchesDate = true;
            final retDate = DateTime.tryParse(ret.date);
            if (retDate != null) {
              if (_startDate != null) {
                final startComp = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
                if (retDate.isBefore(startComp)) matchesDate = false;
              }
              if (_endDate != null) {
                final endComp = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
                if (retDate.isAfter(endComp)) matchesDate = false;
              }
            }

            return matchesQuery && matchesDate;
          }).toList();

          if (filteredReturns.isEmpty) {
            return _buildEmptyState(
              icon: LucideIcons.cornerUpLeft,
              message: 'لا توجد فواتير مرتجعات مطابقة للفلاتر الحالية.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredReturns.length,
            itemBuilder: (context, index) {
              final ret = filteredReturns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(LucideIcons.cornerUpLeft, color: Colors.red),
                  ),
                  title: Text(
                    'رقم الفاتورة الأصلية: ${ret.salesInvoiceId.length > 8 ? ret.salesInvoiceId.substring(0, 8) : ret.salesInvoiceId}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'تاريخ المرتجع: ${ret.date.split("T").first} | العميل: ${ret.customerName ?? "زبون نقدي كاش"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${ret.total.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        ret.isSynced ? LucideIcons.cloudLightning : LucideIcons.cloudOff,
                        color: ret.isSynced ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronDown),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ret.reason != null && ret.reason!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.info, size: 16, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    'سبب الإرجاع: ${ret.reason}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          const Text(
                            'الأدوية المرجعة في الفاتورة:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Table(
                            border: TableBorder.all(color: Colors.grey.withOpacity(0.3)),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.black12),
                                children: [
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الكمية المرجعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الإجمالي المسترد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                              ),
                              ...ret.items.map((item) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? 'دواء غير معروف', style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString(), style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text('${item.sellingPrice} ج.م', style: const TextStyle(fontSize: 12))),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text('${item.total} ج.م', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red))),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: Text('جاري التحميل...'));
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor;
    switch (status) {
      case 'مدفوع':
        color = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'معلق':
        color = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'ملغى':
      default:
        color = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
