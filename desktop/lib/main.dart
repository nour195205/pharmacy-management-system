import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/core/theme/app_theme.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/features/medicines/presentation/pages/medicines_page.dart';
import 'package:desktop/shared/pages/customers_page.dart';
import 'package:desktop/shared/pages/dashboard_page.dart';
import 'package:desktop/shared/pages/reports_page.dart';
import 'package:desktop/shared/pages/sales_page.dart';
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
        BlocProvider<MedicinesBloc>(
          create: (context) => di.sl<MedicinesBloc>(),
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
          customersPage: const CustomersPage(),
          salesPage: const SalesPage(),
          reportsPage: const ReportsPage(),
        ),
      ),
    );
  }
}
