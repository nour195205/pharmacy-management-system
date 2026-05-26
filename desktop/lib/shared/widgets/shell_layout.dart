import 'package:flutter/material.dart';
import 'package:desktop/services/sync_service.dart';
import 'package:desktop/shared/widgets/sidebar.dart';

class ShellLayout extends StatefulWidget {
  final SyncService syncService;
  final Widget dashboardPage;
  final Widget medicinesPage;
  final Widget inventoryPage;
  final Widget purchasesPage;
  final Widget customersPage;
  final Widget salesPage;
  final Widget reportsPage;

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
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Trigger initial sync on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.syncService.syncQueue();
      widget.syncService.syncFromServer();
    });
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
