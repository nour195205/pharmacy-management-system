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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh FAB label when tab changes
    });
    context.read<SalesInvoicesBloc>().add(const LoadSalesInvoicesEvent());
    context.read<SalesReturnsBloc>().add(const LoadSalesReturnsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المبيعات ومرتجعات المبيعات (POS)'),
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
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is SalesInvoicesErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<SalesReturnsBloc, SalesReturnsState>(
            listener: (context, state) {
              if (state is SalesReturnOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is SalesReturnsErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInvoicesTab(context),
            _buildReturnsTab(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSalesInvoicePage()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSalesReturnPage()));
          }
        },
        icon: const Icon(LucideIcons.plus),
        label: Text(_tabController.index == 0 ? 'شاشة بيع جديدة (POS)' : 'مرتجع مبيعات جديد'),
      ),
    );
  }

  Widget _buildInvoicesTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<SalesInvoicesBloc, SalesInvoicesState>(
      builder: (context, state) {
        if (state is SalesInvoicesLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesInvoicesLoadedState) {
          if (state.invoices.isEmpty) {
            return const Center(child: Text('لا توجد فواتير مبيعات حالياً.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.invoices.length,
            itemBuilder: (context, index) {
              final invoice = state.invoices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: const Icon(LucideIcons.fileText, color: Colors.teal),
                  ),
                  title: Row(
                    children: [
                      Text('العميل: ${invoice.customerName ?? "كاش / نقدي"}'),
                      const SizedBox(width: 12),
                      _buildStatusBadge(invoice.status),
                    ],
                  ),
                  subtitle: Text('التاريخ: ${invoice.date.split("T").first} | الدفع: ${invoice.paymentMethod} | الإجمالي: ${invoice.total} ج.م'),
                  trailing: Icon(
                    invoice.isSynced ? LucideIcons.cloudLightning : LucideIcons.cloudOff,
                    color: invoice.isSynced ? Colors.green : Colors.grey,
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
                              child: Text('ملاحظات الفاتورة: ${invoice.note}'),
                            ),
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
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...invoice.items.map((item) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? 'دواء غير معروف')),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString())),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.price.toString())),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.total.toString())),
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

  Widget _buildReturnsTab(BuildContext context) {
    return BlocBuilder<SalesReturnsBloc, SalesReturnsState>(
      builder: (context, state) {
        if (state is SalesReturnsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesReturnsLoadedState) {
          if (state.returns.isEmpty) {
            return const Center(child: Text('لا توجد فواتير مرتجعات حالياً.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.returns.length,
            itemBuilder: (context, index) {
              final ret = state.returns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(LucideIcons.cornerUpLeft, color: Colors.red),
                  ),
                  title: Text('رقم الفاتورة الأصلية: ${ret.salesInvoiceId.substring(0, ret.salesInvoiceId.length > 8 ? 8 : ret.salesInvoiceId.length)}...'),
                  subtitle: Text('تاريخ المرتجع: ${ret.date.split("T").first} | العميل: ${ret.customerName ?? "كاش / نقدي"}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${ret.total} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Icon(
                        ret.isSynced ? LucideIcons.cloudLightning : LucideIcons.cloudOff,
                        color: ret.isSynced ? Colors.green : Colors.grey,
                        size: 16,
                      ),
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
                              child: Text('السبب: ${ret.reason}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
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
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الكمية المرتجعة', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الإجمالي المسترد', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...ret.items.map((item) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? 'دواء غير معروف')),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString())),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.sellingPrice.toString())),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.total.toString())),
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
}
