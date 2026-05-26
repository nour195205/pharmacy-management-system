import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_state.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_state.dart';
import 'package:desktop/features/purchases/presentation/pages/create_purchase_invoice_page.dart';
import 'package:desktop/features/purchases/presentation/pages/create_purchase_return_page.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PurchaseInvoicesBloc>().add(const LoadPurchaseInvoicesEvent());
    context.read<PurchaseReturnsBloc>().add(const LoadPurchaseReturnsEvent());
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
        title: const Text('المشتريات والمرتجعات'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.slate600,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'فواتير الشراء', icon: Icon(LucideIcons.shoppingCart)),
            Tab(text: 'مرتجعات الشراء', icon: Icon(LucideIcons.cornerUpLeft)),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PurchaseInvoicesBloc, PurchaseInvoicesState>(
            listener: (context, state) {
              if (state is PurchaseInvoiceOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is PurchaseInvoicesErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<PurchaseReturnsBloc, PurchaseReturnsState>(
            listener: (context, state) {
              if (state is PurchaseReturnOperationSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is PurchaseReturnsErrorState) {
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePurchaseInvoicePage()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePurchaseReturnPage()));
          }
        },
        icon: const Icon(LucideIcons.plus),
        label: Text(_tabController.index == 0 ? 'فاتورة شراء جديدة' : 'مرتجع جديد'),
      ),
    );
  }

  Widget _buildInvoicesTab(BuildContext context) {
    return BlocBuilder<PurchaseInvoicesBloc, PurchaseInvoicesState>(
      builder: (context, state) {
        if (state is PurchaseInvoicesLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PurchaseInvoicesLoadedState) {
          if (state.invoices.isEmpty) {
            return const Center(child: Text('لا توجد فواتير شراء حالياً.'));
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
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: const Icon(LucideIcons.fileText, color: Colors.blue),
                  ),
                  title: Text('المورد: \${invoice.supplierName ?? "غير محدد"}'),
                  subtitle: Text('التاريخ: \${invoice.invoiceDate} | الإجمالي: \${invoice.totalAmount} ج.م'),
                  trailing: Icon(
                    invoice.isSynced ? LucideIcons.cloudLightning : LucideIcons.cloudOff,
                    color: invoice.isSynced ? Colors.green : Colors.grey,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.slate800 
                          : AppColors.slate50,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                              Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? '')),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString())),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text(item.purchasePrice.toString())),
                              Padding(padding: const EdgeInsets.all(8.0), child: Text((item.quantity * item.purchasePrice).toString())),
                            ],
                          )),
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
    return BlocBuilder<PurchaseReturnsBloc, PurchaseReturnsState>(
      builder: (context, state) {
        if (state is PurchaseReturnsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PurchaseReturnsLoadedState) {
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
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    child: const Icon(LucideIcons.cornerUpLeft, color: Colors.red),
                  ),
                  title: Text('رقم الفاتورة الأصلية: \${ret.purchaseInvoiceId}'),
                  subtitle: Text('التاريخ: \${ret.date} | المورد: \${ret.supplierName ?? "غير محدد"}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\${ret.total} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
                              child: Text('السبب: \${ret.reason}'),
                            ),
                          Table(
                            border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.black12),
                                children: [
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الدواء', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('رقم التشغيلة', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(8.0), child: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...ret.items.map((item) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.medicineName ?? '')),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.batchNumber ?? '')),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toString())),
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
}
