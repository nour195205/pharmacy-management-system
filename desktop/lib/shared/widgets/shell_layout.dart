import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop/services/sync_service.dart';
import 'package:desktop/shared/widgets/sidebar.dart';

import 'package:desktop/features/medicines/presentation/bloc/medicines_bloc.dart';
import 'package:desktop/features/medicines/presentation/bloc/medicines_event.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_bloc.dart';
import 'package:desktop/features/inventory/presentation/bloc/batches_event.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:desktop/features/customers/presentation/bloc/customers_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_invoices_event.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_bloc.dart';
import 'package:desktop/features/purchases/presentation/bloc/purchase_returns_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_invoices_event.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_bloc.dart';
import 'package:desktop/features/sales/presentation/bloc/sales_returns_event.dart';

class ShellLayout extends StatefulWidget {
  final SyncService syncService;
  final Widget dashboardPage;
  final Widget medicinesPage;
  final Widget inventoryPage;
  final Widget purchasesPage;
  final Widget customersPage;
  final Widget salesPage;
  final Widget reportsPage;
  final Widget settingsPage;

  const ShellLayout({
    super.key,
    required this.syncService,
    required this.dashboardPage,
    required this.medicinesPage,
    required this.inventoryPage,
    required this.purchasesPage,
    required this.customersPage,
    required this.salesPage,
    required this.reportsPage,
    required this.settingsPage,
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  int _currentIndex = 0;
  StreamSubscription<SyncStatus>? _syncSubscription;

  @override
  void initState() {
    super.initState();
    // Trigger initial sync on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.syncService.syncQueue();
      widget.syncService.syncFromServer();
    });

    // Auto-reload all BLoCs when database sync completes
    _syncSubscription = widget.syncService.syncStatusStream.listen((status) {
      if (status == SyncStatus.synced) {
        if (mounted) {
          context.read<MedicinesBloc>().add(const LoadMedicinesEvent());
          context.read<BatchesBloc>().add(const LoadBatchesEvent());
          context.read<CustomersBloc>().add(const LoadCustomersEvent());
          context.read<PurchaseInvoicesBloc>().add(const LoadPurchaseInvoicesEvent());
          context.read<PurchaseReturnsBloc>().add(const LoadPurchaseReturnsEvent());
          context.read<SalesInvoicesBloc>().add(const LoadSalesInvoicesEvent());
          context.read<SalesReturnsBloc>().add(const LoadSalesReturnsEvent());
        }
      }
    });
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL layout for Arabic localization
      child: Scaffold(
        body: StreamBuilder<SyncStatus>(
          stream: widget.syncService.syncStatusStream,
          initialData: SyncStatus.synced,
          builder: (context, snapshot) {
            final syncStatus = snapshot.data ?? SyncStatus.synced;
            return Row(
              children: [
                AppSidebar(
                  selectedIndex: _currentIndex,
                  syncStatus: syncStatus,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  onManualSync: () {
                    widget.syncService.syncQueue();
                    widget.syncService.syncFromServer();
                  },
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        widget.dashboardPage,
                        widget.medicinesPage,
                        widget.inventoryPage,
                        widget.purchasesPage,
                        widget.customersPage,
                        widget.salesPage,
                        widget.reportsPage,
                        widget.settingsPage,
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
