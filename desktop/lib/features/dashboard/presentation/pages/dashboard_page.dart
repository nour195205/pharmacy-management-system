import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:desktop/core/theme/app_colors.dart';
import 'package:desktop/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:desktop/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم والإحصائيات العامة'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              context.read<DashboardBloc>().add(const RefreshDashboardEvent());
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardErrorState) {
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
                      context.read<DashboardBloc>().add(const LoadDashboardEvent());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoadedState) {
            return _buildDashboardContent(context, state.data, isDark);
          }

          // Initial state — show welcome with loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data, bool isDark) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'أهلاً بك مجدداً في نظام إدارة الصيدلية 👋',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'إليك نظرة سريعة على أداء العمليات اليوم وحالة المخزون.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 24),

          // Top Aggregate Stat Cards — matching Laravel dashboard.blade.php
          Row(
            children: [
              _buildStatCard(
                context,
                title: 'صافي المبيعات (اليوم)',
                value: '${_formatNumber(data.netSalesToday)} ج.م',
                description: 'إجمالي مبيعات اليوم بعد خصم المرتجعات',
                icon: LucideIcons.trendingUp,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                title: 'صافي المشتريات (اليوم)',
                value: '${_formatNumber(data.netPurchasesToday)} ج.م',
                description: 'إجمالي المشتريات اليوم بعد خصم المرتجعات',
                icon: LucideIcons.shoppingBag,
                color: Colors.cyan,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                title: 'عدد الأدوية المسجلة',
                value: '${data.totalMedicines}',
                description: 'إجمالي الأدوية في قاعدة البيانات',
                icon: LucideIcons.pill,
                color: Colors.teal,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                title: 'عدد الموردين',
                value: '${data.totalSuppliers}',
                description: 'إجمالي الموردين المسجلين',
                icon: LucideIcons.truck,
                color: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Alert Tables — matching Laravel dashboard.blade.php exactly
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Low Stock Medicines Alert Table
              Expanded(
                child: _buildLowStockTable(context, data.lowStockMedicines, isDark),
              ),
              const SizedBox(width: 20),
              // Expiring Soon Batches Alert Table
              Expanded(
                child: _buildExpiringSoonTable(context, data.expiringSoonBatches, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == 0) return '0.00';
    // Format with commas and 2 decimal places
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add commas to integer part
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0 && intPart[i] != '-') {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
      count++;
    }
    return '${buffer.toString().split('').reversed.join()}.$decPart';
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Low Stock Medicines Table — matches Laravel dashboard.blade.php "أدوية على وشك النفاذ"
  Widget _buildLowStockTable(BuildContext context, List<LowStockItem> items, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — matches "bg-warning" in Laravel blade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: Colors.amber[800], size: 20),
                const SizedBox(width: 10),
                Text(
                  'تنبيه: أدوية على وشك النفاذ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
          // Table body
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد أدوية بكميات منخفضة.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                  ),
                ),
              ),
            )
          else
            ...items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.medicineName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatQuantityDisplay(item.totalQuantity),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Expiring Soon Batches Table — matches Laravel dashboard.blade.php "أدوية على وشك انتهاء الصلاحية"
  Widget _buildExpiringSoonTable(BuildContext context, List<ExpiringSoonItem> items, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — matches "bg-danger" in Laravel blade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Text(
                  'تنبيه: أدوية على وشك انتهاء الصلاحية (90 يوم)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          // Table body
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد أدوية ستنتهي صلاحيتها قريباً.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                  ),
                ),
              ),
            )
          else
            ...items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${item.medicineName} (تشغيلة: ${item.batchNumber})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatDateDisplay(item.expiryDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatQuantityDisplay(double qty) {
    if (qty == qty.toInt().toDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2);
  }

  String _formatDateDisplay(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
