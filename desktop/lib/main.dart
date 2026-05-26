import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/core/theme/app_theme.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:desktop/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_bloc.dart';
import 'package:desktop/features/inventory/presentation/pages/batches_page.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/features/medicines/presentation/pages/medicines_page.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_bloc.dart';
import 'package:desktop/features/purchases/presentation/pages/purchases_page.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_bloc.dart';
import 'package:desktop/shared/pages/reports_page.dart';
import 'package:desktop/shared/pages/sales_page.dart';
import 'package:desktop/shared/pages/core_data_page.dart';
import 'package:desktop/shared/widgets/shell_layout.dart';
import 'package:desktop/injection_container.dart' as di;

void main() async {
  // Ensure Flutter engine bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies in Service Locator
  await di.init();

  runApp(const PharmacyManagementSystemApp());
}

class PharmacyManagementSystemApp extends StatelessWidget {
  const PharmacyManagementSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider<BatchesBloc>(
          create: (context) => di.sl<BatchesBloc>(),
        ),
        BlocProvider<MedicinesBloc>(
          create: (context) => di.sl<MedicinesBloc>(),
        ),
        BlocProvider<CustomersBloc>(
          create: (context) => di.sl<CustomersBloc>(),
        ),
        BlocProvider<PurchaseInvoicesBloc>(
          create: (context) => di.sl<PurchaseInvoicesBloc>(),
        ),
        BlocProvider<PurchaseReturnsBloc>(
          create: (context) => di.sl<PurchaseReturnsBloc>(),
        ),
        BlocProvider<SalesInvoicesBloc>(
          create: (context) => di.sl<SalesInvoicesBloc>(),
        ),
        BlocProvider<SalesReturnsBloc>(
          create: (context) => di.sl<SalesReturnsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'صيدليتي - نظام إدارة الصيدلية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Responsive theme switching based on OS setting
        home: ShellLayout(
          syncService: di.sl(),
          dashboardPage: const DashboardPage(),
          medicinesPage: const MedicinesPage(),
          inventoryPage: const BatchesPage(),
          purchasesPage: const PurchasesPage(),
          customersPage: const CoreDataPage(),
          salesPage: const SalesPage(),
          reportsPage: const ReportsPage(),
        ),
      ),
    );
  }
}
